# README

## Implementation

Followed a TDD unit-testing approach.
Trying to split the responsiblities into different kinds of objects.
```
controllers: only forward data to services
services: handle the highest level workflow
proxies: wraps 3rd party APIs narrowing their interfaces only to what services need.
```

The other approach would be doing it in `the rails way` which would involve only one integration spec.
And call third party api from the controller.

In real life I would start with the second approach and refactor as requirements evolve into the first approach.
While requirements do not grow much the rails way approach is simple to maintain.

I chose the first approach here to demonstrate that I can think about design and unit-test apprioriately.

## Time spent

Estimated dedication around 4 hrs total.
```
30 min Slack Integration Investigation
2 hrs Coding
    30 min controller
    30 min service
    30 min 3rd party proxy
    30 min integration spec
Deployment & QA 30 min (deployed in fly.io and heroku)
Write Readme 30 min
```

## Running the App locally

Before you start you will need an slack account with a configured workspace.

This app will publish messages to your slack-channel through a URL you must provide.
Follow [these steps](https://api.slack.com/messaging/webhooks#getting_started) in order to obtain a workspace URL so this app can publish message to.

Once you have the URL open .env file and add the incomming webhook url to: `SLACK_INCOMMING_WEBHOOK_URL`

You will need to have `ruby '3.1.2'`
install postgres, rails and gems (postgres shouldn't be needed but I added because heroku requires it)

run the application in one tab
```
$> rails s
```

perform the http post in another tab.

This should return success and post to your slack workspace.
```shell
$> curl -v -H 'Content-type: application/json' --data '{"RecordType": "Bounce","Type": "SpamNotification","TypeCode": 512,"Name": "Spam notification","Tag": "","MessageStream": "outbound", "Description": "The message was delivered, but was either blocked by the user, or classified as spam, bulk mail, or had rejected content.","Email": "zaphod@example.com","From": "notifications@honeybadger.io","BouncedAt": "2023-02-27T21:41:30Z"}' http://localhost:3000/messages
```

This should return error and do not post anything.
```shell
$> curl -v -H 'Content-type: application/json' --data '{ "RecordType": "Bounce", "MessageStream": "outbound", "Type": "HardBounce", "TypeCode": 1, "Name": "Hard bounce", "Tag": "Test", "Description": "The server was unable to deliver your message (ex: unknown user, mailbox not found).", "Email": "arthur@example.com", "From": "notifications@honeybadger.io", "BouncedAt": "2019-11-05T16:33:54.9070259Z" }' http://localhost:3000/messages
```

you send the curl requests agains `https://honeybadger2023.fly.dev/` but that will send the message to my slack-channel.

## Deploying

App is ready to be deployed to Heroku.

```
heroku apps:create --stack=heroku-22
git push heroku main
```
Initially deployed to heroku but then regretted it due to potential credit card charges.
And tried `fly.io`

Deploy to fly.io
install flyctl
You can follow [these instructions](https://fly.io/docs/rails/getting-started/existing/) to deploy.
```
$> fly launch
$> fly deploy
$> fly secrets set SLACK_INCOMMING_WEBHOOK_URL=https://hooks.slack.com/services/....
```

## Drawbacks

#### Error handling.
Current error handling isn't very helpful.
A consumer might send wrong parameters and get back a generic text that doesn't lead him to solve the error.
Rails should handle error too (usually `rescue_from` on application controller), so the consumer doesn't receive long stacktraces.
