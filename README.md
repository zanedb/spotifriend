# Spotifriend

Spotify Friend Activity on iOS.

<!--[Try it on TestFlight!]()-->

## Context

I wrote this app in 2023 with the intention of recreating Spotify's desktop sidebar in Stage Manager.

<img src="https://i.imgur.com/Brkjoek.png" alt="iPad Pro in Stage Manager with the described setup" height="512">

I based the [ViewModel](https://github.com/zanedb/spotifriend/blob/main/spotifriend/FriendActivity.swift) on aviwad's [Friend Activity for Spotify](https://github.com/aviwad/Friend-Activity-for-Spotify), and re-did all the views to my personal preference. It was a great learning experience for SwiftUI.

I no longer use Spotify in this setup, or really that often in general. But a few friends of mine started using it and one in particular swears by it as a social network. So I keep it around on TestFlight, with ~minor~ changes every 90 days.

I think there could be something to the social idea, and [Airbuds](https://apps.apple.com/us/app/airbuds-widget/id1638906106) seems to be the closest to what I'd envision. They don't use Spotify's friend activity endpoint though, instead opting to create their own stats based on official APIs. The downside of this is it requires your friends to be on board to see their stats, though I imagine that's a crucial part of building a network anyway.

In a brief fling with that idea, before I came to my senses, I created an onboarding flow that I'm still pretty proud of from scratch. I based the UI on [Retro](https://retro.app/)'s wonderful one. I made [a whole API](https://github.com/zanedb/spot) for it and everything.

https://github.com/user-attachments/assets/0c5b56ce-efb1-43bc-8b57-97cd7028d208
