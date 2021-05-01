# scripts
Helpful Scripts to test RMF with.

## random_tasks
This script repeatedly issues tasks to a given target fleet, and collects ros2 bags of tasks that failed, for analysis.

Currently, only Loop Tasks are available.

In the following incantation, we will infinitely issue Loop tasks to the tinyRobot fleet based on the waypoints in `office_waypoints.yml`, using sim time.

If the task is not completed with 300.0 seconds, the task is considered to have failed. A ros2 bag of the failed task can be found in the `log` folder.
```
# From the random_tasks folder
 python3 task_generator.py --robot_type tinyRobot --task_config_path office_waypoints.yml  --task_type loop --use_sim_time --task_check_timeout 300.0 
 ```

In this incantation, we save the ros2 bags in the folder `logging` instead, and we only issue 5 tasks.
 ```
 python3 task_generator.py --robot_type tinyRobot --task_config_path office_waypoints.yml  --task_type loop --use_sim_time --task_check_timeout 300.0  --task_count 5  --log_label logging
 ```

 You can integrate Slack by supplying the `SLACK_BOT_TOKEN` and `SLACK_BOT_CHANNEL` environment variables:
```
 # If you want to try Slack integration, you need a API token and Slack App:
 # https://github.com/slackapi/python-slack-sdk/blob/main/tutorial/01-creating-the-slack-app.md
SLACK_BOT_TOKEN=[your-token] SLACK_BOT_CHANNEL=[#your-channel-with-hash] python3 task_generator.py [args]
```

Every time the task fails, a ros2 bag is uploaded to the given `SLACK_BOT_CHANNEL`.

