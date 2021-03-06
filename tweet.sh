#!/bin/bash
#Twitter status update bot
#Author: Luka Pusic <luka@pusic.com>

#REQUIRED PARAMS
username="username"
password="passw0rd"
tweet="$*" #must be less than 140 chars

#EXTRA OPTIONS
uagent="Mozilla/5.0" #user agent (fake a browser)
sleeptime=0 #add pause between requests

if [ $(echo "$tweet" | wc -c) -gt 140 ]; then
	echo "[FAIL] Tweet must not be longer than 140 chars!" && exit 1
elif [ "$tweet" == "" ]; then
	echo "[FAIL] Nothing to tweet. Enter your text as argument." && exit 1
fi

touch "cookie.txt" #create a temp. cookie file

#GRAB LOGIN TOKENS
echo "[+] Fetching twitter.com..." && sleep $sleeptime
initpage=$(curl -s -b "cookie.txt" -c "cookie.txt" -L -A "$uagent" "https://mobile.twitter.com/session/new")
token=$(echo "$initpage" | grep "authenticity_token" | sed -e 's/.*value="//' | cut -d '"' -f 1)

#LOGIN
echo "[+] Submitting the login form..." && sleep $sleeptime
loginpage=$(curl -s -b "cookie.txt" -c "cookie.txt" -L -A "$uagent" -d "authenticity_token=$token&username=$username&password=$password" "https://mobile.twitter.com/session")

#GRAB COMPOSE TWEET TOKENS
echo "[+] Getting compose tweet page..." && sleep $sleeptime
composepage=$(curl -s -b "cookie.txt" -c "cookie.txt" -L -A "$uagent" "https://mobile.twitter.com/compose/tweet")

#TWEET
echo "[+] Posting a new tweet: $tweet..." && sleep $sleeptime
tweettoken=$(echo "$composepage" | grep "authenticity_token" | sed -e 's/.*value="//' | cut -d '"' -f 1 | tail -n 1)
update=$(curl -s -b "cookie.txt" -c "cookie.txt" -L -A "$uagent" -d "wfa=1&authenticity_token=$tweettoken&tweet[text]=$tweet&commit=Tweet" "https://mobile.twitter.com/compose/tweet")

#GRAB LOGOUT TOKENS
logoutpage=$(curl -s -b "cookie.txt" -c "cookie.txt" -L -A "$uagent" "https://mobile.twitter.com/account")

#LOGOUT
echo "[+] Logging out..." && sleep $sleeptime
logouttoken=$(echo "$logoutpage" | grep "authenticity_token" | sed -e 's/.*value="//' | cut -d '"' -f 1 | tail -n 1)
logout=$(curl -s -b "cookie.txt" -c "cookie.txt" -L -A "$uagent" -d "authenticity_token=$logouttoken" "https://mobile.twitter.com/session/destroy")

rm "cookie.txt"
