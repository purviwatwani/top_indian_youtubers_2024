import os
import json
import pandas as pd
from dotenv import load_dotenv
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError

load_dotenv()
API_KEY = os.getenv("YOUTUBE_API_KEY")
youtube = build("youtube", "v3", developerKey=API_KEY)

INPUT_CSV = "influencers.csv"                       # <-- your file
OUTPUT_CSV = "influencers_with_youtube_stats.csv"
CACHE_FILE = "channel_id_cache.json"                # saves quota on reruns

# Load cache of NAME -> channel ID
cache = {}
if os.path.exists(CACHE_FILE):
    with open(CACHE_FILE) as f:
        cache = json.load(f)


def find_channel_id(name):
    """Turn a NAME value into a YouTube channel ID."""
    name = str(name).strip()
    if not name or name.lower() == "nan":
        return None
    if name in cache:
        return cache[name]

    channel_id = None
    try:
        if name.startswith("UC") and len(name) == 24:
            channel_id = name  # already a channel ID
        elif name.startswith("@"):
            # Handle lookup: 1 quota unit
            r = youtube.channels().list(part="id", forHandle=name).execute()
            items = r.get("items", [])
            channel_id = items[0]["id"] if items else None
        else:
            # Name search: 100 quota units
            r = youtube.search().list(
                part="snippet", q=name, type="channel", maxResults=1
            ).execute()
            items = r.get("items", [])
            channel_id = items[0]["snippet"]["channelId"] if items else None
    except HttpError as e:
        print(f"API error for '{name}': {e}")
        return None

    cache[name] = channel_id
    return channel_id


def get_stats(channel_ids):
    """Fetch stats for many channels, 50 per request."""
    results = {}
    ids = [c for c in channel_ids if c]
    for i in range(0, len(ids), 50):
        batch = ids[i:i + 50]
        r = youtube.channels().list(
            part="snippet,statistics", id=",".join(batch)
        ).execute()
        for item in r.get("items", []):
            s = item["statistics"]
            results[item["id"]] = {
                "yt_channel_title": item["snippet"]["title"],
                "total_subscribers": s.get("subscriberCount"),  # None if hidden
                "total_views": s.get("viewCount"),
                "total_videos": s.get("videoCount"),
            }
    return results


df = pd.read_csv(INPUT_CSV)

# 1. Resolve each NAME to a channel ID
df["yt_channel_id"] = df["NAME"].apply(find_channel_id)

# Save cache
with open(CACHE_FILE, "w") as f:
    json.dump(cache, f)

# 2. Fetch stats in batches
stats = get_stats(df["yt_channel_id"].dropna().unique().tolist())
stats_df = pd.DataFrame.from_dict(stats, orient="index")
stats_df.index.name = "yt_channel_id"
stats_df = stats_df.reset_index()

# 3. Merge on channel ID (keeps rows aligned, unlike concat)
combined = df.merge(stats_df, on="yt_channel_id", how="left")

combined.to_csv(OUTPUT_CSV, index=False)
print(combined.head(10))
print(f"\nSaved to {OUTPUT_CSV}")
