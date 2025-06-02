import os
import requests
import praw

client_id = os.getenv("REDDIT_CLIENT_ID")
client_secret = os.getenv("REDDIT_CLIENT_SECRET")
discord_webhook = os.getenv("DISCORD_WEBHOOK_ANIME")

# Reddit API credentials
reddit = praw.Reddit(
    client_id=client_id,
    client_secret=client_secret,
    user_agent="anime-top-10-script by u/WhaThaFuc",  # Replace YOUR_USERNAME
    config_interpolation='basic'  # Add this argument to avoid the deprecation warning in PRAW 8+
)

# Search subreddit
query = 'top 10 anime "Anime Corner"'
subreddit = reddit.subreddit("anime")
results = subreddit.search(query, sort="new", limit=5)

# Extract image from first post (if available)
image_url = None
for post in results:
    if post.url.endswith(('.jpg', '.jpeg', '.png', '.gif', '.webp')):
        image_url = post.url
        print("Found image post:", post.title)
        break

if not image_url:
    print("no image found")

# Send to Discord
if discord_webhook:
    response = requests.post(discord_webhook, json={
        "username": "Anime",
        "avatar_url": "https://styles.redditmedia.com/t5_2qh22/styles/communityIcon_18jg89hnk9ae1.png",
        "content": image_url
    })
    print("Posted to Discord:", response.status_code)
else:
    print("webhook not set.")
