import re
import subprocess
import discord

from os import listdir
from Message import Message

intents = discord.Intents.default()
intents.message_content = True

client = discord.Client(intents=intents)

weekly_anime_id = 1221920619487039618
starlight_test_channel_id = 1043384233261006888
default_channel_id = weekly_anime_id

testing = False
firstRun = False

_messages = []
_folderMode = None
INSTALL_FOLDER = '/home/maqo/amine-bot/'
SHANA_FOLDER = '/home/maqo/mercury/media/downloads/ShanaProject/'


async def send_message(msg, channel_id=default_channel_id):
    c = client.get_channel(channel_id)
    # Image embedding not implemented because mal link is enough
    await c.send(msg.message + "\n" + msg.link)
    await client.close()


def get_shows() -> list[str]:
    files = listdir(SHANA_FOLDER + 'Unwatched/')
    shows = []

    for file in files:
        results = re.search(r'\[.*\] (.*?) - (\d{1,3}).*', file)
        name = results.group(1)
        episode = int(results.group(2))
        print(f"{name} E{episode:02d}")
        shows.append(f"{name}\tE{episode:02d}")

    shows.sort()
    return shows

async def get_and_process_history(channel_id=default_channel_id):
    history = client.get_channel(channel_id).history()
    message = None

    async for m in history:
        if m.content.startswith("oWo") and m.author.id == client.user.id:
            message = m
            break
        else:
            # sometimes humans are dumb
            if m.content.startswith("!watch "):
                m.content.replace("!watch", "!watched")
            if m.content.startswith("!watched"):
                regex = re.search(r"!watched(.*?)(\d+)", m.content, re.IGNORECASE)
                title = regex.group(1).strip()
                episode = regex.group(2).strip()
                print (f"Marking [{title}] [{episode}] as watched")
                r = subprocess.run([INSTALL_FOLDER + "movetowatched.pl", title, episode])
                print ("Run result", r)
            await m.delete()
    
    files = []

    text = "oWo\nAny posts below this will be boiled ^_^\n# Unwatched Episodes: "
 
    if firstRun:
        await send_message(Message(text))
        return

    if message:
        shows = get_shows()
        for show in shows:
            text += "\n" + show

        await message.edit(content = text)

   
@client.event
async def on_ready():
    if testing:
        await send_message(Message("I'm alive"), starlight_test_channel_id)
        return

    print(f"We have logged in as {client.user}")

    if _folderMode:
        await get_and_process_history()
    else:
        print(len(_messages), "message")
        for m in _messages:
            await send_message(m)

    await client.close()

def test(token):
    global testing
    testing = True
    client.run(token)


def begin(token, folderMode, messages=[]):
    global _messages
    global _folderMode
    _messages = messages
    _folderMode = folderMode

    client.run(token)
