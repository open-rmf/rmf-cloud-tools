# scripts
Helpful Scripts to test RMF with.

## task_generator.py
```
 python3 task_generator.py --robot_type tinyRobot --task_config_path ../random_loops/loop_points.yml  --task_type loop --use_sim_time --task_check_timeout 300.0 

 # If you want to try Slack integration, you need a API token and uncomment the relevant paragraph in the _handle_task_failure function
 # https://github.com/slackapi/python-slack-sdk/blob/main/tutorial/01-creating-the-slack-app.md
SLACK_BOT_TOKEN=[your-token] SLACK_BOT_CHANNEL=[#your-channel-with-hash] python3 task_generator.py [args]
```

