# CSE438_FinalProject

## Notes
- Because we used the Spotify api our app will not run in the simulator and must be tested on a physical device. I believe a Spotify premium account may be required but I'm not certain on that. 
- Due to issues with getting recommendations from the Apple Music api we switched to the Spotify api. I believe we touched on the fact that we werent concrete on which api we planned to use but we had mentioned using Apple Music before.
- We wanted to add songs to a playlist when the user liked them but further authorization was required. The documentation on how to get this authorization was severely lacking on recent ios versions so we instead put a link to the spotify app in the song list view where the user can view past responses. 
- We weren't able to simply play a preview of the song so we instead played the new song when the card was presented. 
