# scripts

Bunch of helper scripts when doing RMF testing!

## random_loops
Sends Loop Tasks based on randomly selected graph names specified in the provided config file.
```
cd random_loops
python3 random_loops.py --robot_type tinyRobot --config_file loop_points.yml  --use_sim_time                            # Keeps sending Loop Tasks for tinyRobot fleet, using sim_time
python3 random_loops.py --robot_type deliveryRobot --config_file loop_points.yml                                        # Keeps sending Loop Tasks for deliveryRobot, using non sim_time
python3 random_loops.py --robot_type deliveryRobot --config_file loop_points.yml --task_priority 1 --task_count 5       # Keeps sending Loop Tasks for deliveryRobot, using non sim_time, for only 5 tasks, with priority 1
```
