#!/usr/bin/env python3

# Copyright 2021 Open Source Robotics Foundation, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys
import uuid
import time
import argparse
import random
import yaml
import math

import rclpy
from rclpy.node import Node
from rclpy.parameter import Parameter
from rmf_task_msgs.srv import SubmitTask, GetTaskList
from rmf_task_msgs.msg import TaskType, Loop


class RandomLoopTaskRequester:
  def __init__(self, argv=sys.argv):

    # Get all input parameters
    parser = argparse.ArgumentParser()
    parser.add_argument("--task_priority", type=int, default=0,
                        help='Priority for publishing tasks, default: 0')
    parser.add_argument("--task_count", type=int, default=None,
                        help='Number of tasks to issue, default: None ( infinite )')
    parser.add_argument("--robot_type", required=True, type=str,
                        help='Name of Robot fleet')
    parser.add_argument("--config_file", required=True, type=str,
                        help='path to YAML file with all loop points')
    parser.add_argument("--use_sim_time", action="store_true",
                    help='Use sim time, default: false')

    # initialization with given parameters
    self.args = parser.parse_args(argv[1:])

    # Load loop points
    with open(self.args.config_file) as config_file:
      self.loop_points = yaml.load(config_file, Loader=yaml.FullLoader)

    # Required
    self.node = rclpy.create_node('random_task_requester')
    self.robot_type = self.args.robot_type
    self.config_file_path = self.args.config_file


    # Optionals
    self.node.set_parameters([Parameter("use_sim_time", Parameter.Type.BOOL, self.args.use_sim_time)])
    if self.args.task_count is None:
      self.task_count = math.inf
    else:
      self.task_count = self.args.task_count
    self.task_priority = self.args.task_priority

    # ROS2 plumbing
    self.submit_task_srv = self.node.create_client(
        SubmitTask, '/submit_task')
    self.get_task_list_srv = self.node.create_client(
        GetTaskList, '/get_tasks')

  def choose_loop_points(self):
    random_points = random.sample(self.loop_points, 1)
    self.start_wp = random_points[0]
    self.finish_wp = random_points[0]

  def generate_task_req_msg(self):
    self.choose_loop_points()

    req_msg = SubmitTask.Request()
    req_msg.description.task_type.type = TaskType.TYPE_LOOP

    loop = Loop()
    loop.num_loops = 1
    loop.start_name = self.start_wp
    loop.finish_name = self.finish_wp
    loop.robot_type = self.robot_type
    req_msg.description.loop = loop

    ros_start_time = self.node.get_clock().now().to_msg()
    ros_start_time.sec += 0
    req_msg.description.start_time = ros_start_time

    req_msg.description.priority.value = self.task_priority
    return req_msg

  def main(self):
    iterations = 0
    while iterations < self.task_count:
      iterations += 1

      if not self.submit_task_srv.wait_for_service(timeout_sec=3.0):
        self.node.get_logger().error('Dispatcher Node is not available')
        continue

      # Create message
      rclpy.spin_once(self.node, timeout_sec=1.0)
      req_msg = self.generate_task_req_msg()

      # Submit loop request
      self.node.get_logger().info("Submitting Loop Request")
      try:
        future = self.submit_task_srv.call_async(req_msg)
        rclpy.spin_until_future_complete(
            self.node, future, timeout_sec=1.0)
        response = future.result()
        if response is None:
          self.node.get_logger().error('/submit_task srv call failed')
        elif not response.success:
          self.node.get_logger().error(
              'Dispatcher node failed to accept task')
        else:
          self.node.get_logger().info(
              'Request was successfully submitted '
              f'and assigned task_id: [{response.task_id}]')
          self.tracked_task_id = response.task_id

        # Wait for task completion / failure by examining TaskList
        while True:
          req_msg = GetTaskList.Request()
          future = self.get_task_list_srv.call_async(req_msg)
          rclpy.spin_until_future_complete(
              self.node, future, timeout_sec=1.0)
          response = future.result()

          if response is None:
            self.node.get_logger().error('/get_task srv call failed')

          elif not response.success:
            self.node.get_logger().error(
                'Something wrong happened getting tasks')
          else:
            pass

          if any(self.tracked_task_id == x.task_profile.task_id for x in response.active_tasks):
            self.node.get_logger().info(
                f'waiting for task {self.tracked_task_id} arrival at {self.finish_wp}')
            time.sleep(3)
          else:
            self.node.get_logger().info(
                f'Task {self.tracked_task_id} completed. saving..')
            with open('random_loop_log.txt', 'w') as f:
              for item in response.terminated_tasks:
                f.write("%s\n" % item)
            break

      except Exception as e:
        self.node.get_logger().error('Error! Submit Srv failed %r' % (e,))

    self.node.get_logger().info(f"Finished {iterations} requests")

###############################################################################


def main(argv=sys.argv):
  rclpy.init(args=sys.argv)
  args_without_ros = rclpy.utilities.remove_ros_args(sys.argv)

  task_requester = RandomLoopTaskRequester(args_without_ros)
  task_requester.main()
  rclpy.shutdown()


if __name__ == '__main__':
  main(sys.argv)
