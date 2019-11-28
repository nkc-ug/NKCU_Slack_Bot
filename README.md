# NKCUG-Slack-Bot

SlackBot container service building on Ruby.

# Command in slack
+ 今日も一日
  + Return a image(inspire: [zoi.herokuapp.com](https://zoi.herokuapp.com/))

# Usage 

1. Issue a Token from [SlackAPI](https://api.slack.com/).
  + You can use `Bots` app. Search it in your workspace apps.

2. Create `.env` file and write slack api token.

```.env
SLACK_API_KEY=INSERT_HERE
```
The file structure should be like this.
```
.
├── .env
├── .git
├── .gitignore
├── README.md
├── application
├── docker
└── docker-compose.yml
```

3. Starting Container.

```bash
$ docker-compose up -d
```