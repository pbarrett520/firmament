return {
  ["00eabd78-7da0-4908-af9a-4446cd004877"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "Ask Prism who you are.",
    uuid = "00eabd78-7da0-4908-af9a-4446cd004877"
  },
  ["0fa37749-f1c5-4864-828a-5b93d3a133f7"] = {
    children = {
      "a273cb75-765a-4b6a-96b0-9c81b8922998"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "A little overzealous. The goo makes you lose traction, and your shoulder slams into the table where you're resting.",
    uuid = "0fa37749-f1c5-4864-828a-5b93d3a133f7",
    who = "narrator"
  },
  ["00fbb92f-9013-4e86-8d69-13432d7ba8b1"] = {
    children = {
      "616fe3b4-bdf1-4081-8f48-a56ea3f18ddc"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Prism stops for just a moment, before deciding that it's easier for him to let you continue whatever it is you're doing.",
    uuid = "00fbb92f-9013-4e86-8d69-13432d7ba8b1",
    who = "narrator"
  },
  ["1b5c3354-2067-4b4a-8474-2a7496f14641"] = {
    children = {
      "4897187e-8a72-4403-a4ab-c2aa72d35197"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "To your great surprise, your corpus resembles that of the speaking creature. You see a large torso, with two legs sprouting from the bottom and two arms from the sides. Your skin is a neutral almond color. ",
    uuid = "1b5c3354-2067-4b4a-8474-2a7496f14641",
    who = "narrator"
  },
  ["1c5eeecd-c86c-4049-b0fd-cb07b273f453"] = {
    children = {
      "78ad5998-471f-4997-9c6c-6e0ebff60b86"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "No, I know what existence means. I know what the universe is. I'm not an infant. But what is a Dome?",
    uuid = "1c5eeecd-c86c-4049-b0fd-cb07b273f453",
    who = "pc"
  },
  ["2a8b3a7e-afb0-4fcc-aada-3d9b2926f57f"] = {
    children = {
      "042d3077-14b3-4fcc-b4c6-b329b4123402"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "There he goes. It looks like he's almost with us. You reading me, buddy? I'm Prism. You're safe here. Cryo weirdness should be wearing off within the half hour. Just let me know when you're picking this up.",
    uuid = "2a8b3a7e-afb0-4fcc-aada-3d9b2926f57f",
    who = "unknown_waker"
  },
  ["2c45bc90-90c6-43a4-930f-b6e4f2ace348"] = {
    children = {
      "e9c1b8fa-19b1-4644-8cbd-c18e4361c49e"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "Ask Prism where you are.",
    uuid = "2c45bc90-90c6-43a4-930f-b6e4f2ace348"
  },
  ["2ea1f28a-13c3-4085-930f-e3851e78cf21"] = {
    children = {
      "1c5eeecd-c86c-4049-b0fd-cb07b273f453"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "I really should have consulted the Manual before this...",
    uuid = "2ea1f28a-13c3-4085-930f-e3851e78cf21",
    who = "prism"
  },
  ["3ad2ff15-315e-411c-911e-9a530a1e8a4a"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "Ask Prism who he is.",
    uuid = "3ad2ff15-315e-411c-911e-9a530a1e8a4a"
  },
  ["4cf0f09c-a008-4a51-94c7-d895ceb48c54"] = {
    children = {
      "38730ce5-bbac-4ea2-a664-9069dfc0ab4e"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You can feel the bindings between your mind and that of the fog beginning to release. They dissolve like old glue under heat, melting, and you feel your mind's energy separate and return to you as if through a sieve. One thing begins to form in your newborn mind, an idea. It must escape...",
    uuid = "4cf0f09c-a008-4a51-94c7-d895ceb48c54",
    who = "narrator"
  },
  ["4dd97088-8eae-43fc-b186-ff74588cdaaf"] = {
    children = {
      "05c7c73d-ef65-45a0-86d5-712bcebe0fba"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "The world? Reality? The Dome? The universe? I'm not sure what you mean...",
    uuid = "4dd97088-8eae-43fc-b186-ff74588cdaaf",
    who = "prism"
  },
  ["05c7c73d-ef65-45a0-86d5-712bcebe0fba"] = {
    children = {
      "d7991ec9-13d9-427d-b6ed-9e6aa3e6e038"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "One of these sticks out to you. The Dome?",
    uuid = "05c7c73d-ef65-45a0-86d5-712bcebe0fba",
    who = "narrator"
  },
  ["6a2f7cca-739f-48c3-98bc-56eba60066b5"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "What is the Manual?",
    uuid = "6a2f7cca-739f-48c3-98bc-56eba60066b5"
  },
  ["6f6e600b-9ebc-41a1-b6be-8d3dfc7ee631"] = {
    branch_on = "intro.heard_manual",
    children = {
      "6a2f7cca-739f-48c3-98bc-56eba60066b5"
    },
    is_entry_point = false,
    kind = "If",
    uuid = "6f6e600b-9ebc-41a1-b6be-8d3dfc7ee631"
  },
  ["6fa955b6-71cf-4c39-9828-e5cdf4dadd59"] = {
    children = {
      "2ea1f28a-13c3-4085-930f-e3851e78cf21"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Wow. I'd heard stories, but I didn't think they were true. You're...you're like an infant still sticky with uterine replicator fluid. Even basic concepts such as existence are foreign to you!",
    uuid = "6fa955b6-71cf-4c39-9828-e5cdf4dadd59",
    who = "prism"
  },
  ["7bf4aa0d-0ffc-4e34-9b96-2970dccc886b"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "You're getting nervous about Prism leaving his psychocomputational coma. You should just sit down.",
    uuid = "7bf4aa0d-0ffc-4e34-9b96-2970dccc886b"
  },
  ["07c7ec55-b5b1-447b-bb3b-ed2b5c2bd788"] = {
    children = {
      "dab180b6-63a6-43bf-be7a-35f6d9efe581"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "The arms, the legs...yes, this makes sense. If you just put your arm here and push like this...",
    uuid = "07c7ec55-b5b1-447b-bb3b-ed2b5c2bd788",
    who = "narrator"
  },
  ["7d443a7c-e20a-44fd-9abf-b316dac820fc"] = {
    children = {
      "00fbb92f-9013-4e86-8d69-13432d7ba8b1"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "After a few attempts, you begin wheezing, and whatever muscles were actuating are out of energy.",
    uuid = "7d443a7c-e20a-44fd-9abf-b316dac820fc",
    who = "narrator"
  },
  ["7fda0c85-d3bd-4279-95c3-36bb359981fb"] = {
    children = {
      "16e9eebf-7a1b-4566-b4a7-62a77ac6f168"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "He seems pretty gone. You should take this chance to get your sea legs.",
    uuid = "7fda0c85-d3bd-4279-95c3-36bb359981fb"
  },
  ["8f63ce97-b340-45b3-9222-b353d002968c"] = {
    children = {},
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You walk to the box, as quietly as you can with your strength. It is made of the same material as everything else in this place: cold, cobalt blue steel without a seam or weld.",
    uuid = "8f63ce97-b340-45b3-9222-b353d002968c",
    who = "narrator"
  },
  ["9b12985b-4a88-42b5-bf12-45bce70d2cc5"] = {
    children = {
      "df57a28b-5160-4c0a-97a9-1b23203c64d2"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "With great strain, you try to remember what it means to address someone. You can't remember how he addressed you -- no data to go on here. After a moment, your feeble mind considers that perhaps anything at all will do.",
    uuid = "9b12985b-4a88-42b5-bf12-45bce70d2cc5",
    who = "unknown"
  },
  ["9c6cb972-34bf-49bb-912f-b2ea307cb922"] = {
    children = {
      "680880a5-dc9b-454c-b24d-3da6302c4cd1",
      "afc3941c-7f88-45d2-92a8-8d89c4650842",
      "141692d1-94a1-4bd7-a314-58e9df1eb7d3"
    },
    internal_id = "rpt_001",
    is_entry_point = false,
    kind = "ChoiceRepeat",
    uuid = "9c6cb972-34bf-49bb-912f-b2ea307cb922"
  },
  ["9c16b265-c570-4cb1-8fb6-a4ccd8251138"] = {
    children = {},
    is_entry_point = false,
    kind = "Return",
    return_to = "polite",
    uuid = "9c16b265-c570-4cb1-8fb6-a4ccd8251138"
  },
  ["11aa766b-7d9f-4fc5-8072-252ea87ce57b"] = {
    children = {
      "497781df-e718-4f90-b7a4-15f0d6e5fe12"
    },
    effects = {
      {
        amplitude = 0.0099999997764825821,
        first = 0,
        frequency = 20,
        last = 2,
        type = 1
      }
    },
    is_entry_point = true,
    kind = "Text",
    text = "You awaken in the warm embrace of an electric caul. There is not light, only warmth and wet. You feel the snarls of not-flesh which snake around your body. They lift you up and up through a never-ending blackness. ",
    uuid = "11aa766b-7d9f-4fc5-8072-252ea87ce57b",
    who = "mind"
  },
  ["16e9eebf-7a1b-4566-b4a7-62a77ac6f168"] = {
    children = {
      "f124cb02-6b59-479a-b130-60ce6ec95360"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Slowly, you ease off the table and onto your feet. The goo has dried remarkably quickly -- you feel completely dry. The room is still mostly empty, smooth walls with no entryways or crevices. The only feature is the hole where the tracks of your coffin leadand a small, metal rolling table near Prism. It is made of the same material as the walls.",
    uuid = "16e9eebf-7a1b-4566-b4a7-62a77ac6f168",
    who = "narrator"
  },
  ["27e2d735-2ab6-4032-b45b-f06f301fa7b2"] = {
    children = {
      "745ec3e3-6ab1-4e40-8355-e22c43b6c419"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Erm...sector 576 of what?",
    uuid = "27e2d735-2ab6-4032-b45b-f06f301fa7b2",
    who = "pc"
  },
  ["39f62dd1-d6a6-4d3f-889b-9729b8dc80f6"] = {
    children = {
      "9c16b265-c570-4cb1-8fb6-a4ccd8251138"
    },
    is_entry_point = false,
    kind = "Set",
    uuid = "39f62dd1-d6a6-4d3f-889b-9729b8dc80f6",
    value = false,
    variable = "intro.fog_is_real"
  },
  ["042d3077-14b3-4fcc-b4c6-b329b4123402"] = {
    children = {
      "9c6cb972-34bf-49bb-912f-b2ea307cb922"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "This is not fog. This is...some sort of creature. On the physical plane. It towers over you. It is clearly a creature borne of natural processes. Biradial symmetry, but with enough variation to know that it is not manufactured. The noise it makes sounds as if it is coming from far away. It is tinny and robotic. ",
    uuid = "042d3077-14b3-4fcc-b4c6-b329b4123402",
    who = "narrator"
  },
  ["59db251a-2621-49e7-9895-e407d8f5156e"] = {
    children = {
      "b092020c-2e5a-440d-a51b-f9fba307b47a"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "The fog is clouding your mind. There is a malevolence to it. It is taking you from the world of the real to the world of the unreal. You must escape this place.",
    uuid = "59db251a-2621-49e7-9895-e407d8f5156e"
  },
  ["71b6df16-7fe7-43fd-99cc-ec0a99b6b924"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "What electronics does a man with two cybernetic eyes need? Walk over and inspect the electronics.",
    uuid = "71b6df16-7fe7-43fd-99cc-ec0a99b6b924"
  },
  ["75ce4d05-1158-45dc-a61f-df7d05e97d85"] = {
    children = {
      "665a44bf-ee02-4a80-bf1c-decea08bfbb5"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You grasp at something in your mind. You're looking for something. You feel that it's something that you should know...",
    uuid = "75ce4d05-1158-45dc-a61f-df7d05e97d85",
    who = "narrator"
  },
  ["78ad5998-471f-4997-9c6c-6e0ebff60b86"] = {
    children = {
      "ae350e72-3d05-4fe1-b02a-5df5e127d3aa"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Hm. Contradictory. I wonder if there are any recorded instances of such a knowledge gap in previous recombinatings...",
    uuid = "78ad5998-471f-4997-9c6c-6e0ebff60b86",
    who = "prism"
  },
  ["78fabde2-2d33-461f-8ce3-f837ac78cc39"] = {
    children = {},
    is_entry_point = false,
    kind = "Return",
    return_to = "ask_prism",
    uuid = "78fabde2-2d33-461f-8ce3-f837ac78cc39"
  },
  ["86dad0f1-f9e8-4e3a-b4ef-aaade4faeb6b"] = {
    children = {
      "d8534f84-ca1e-4597-9a20-fcb42ae4bed8"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "...yeah, you were right, this one's defi....readings are fine, th.......even perking up a b...",
    uuid = "86dad0f1-f9e8-4e3a-b4ef-aaade4faeb6b",
    who = "unknown_waker"
  },
  ["302c29b4-97a6-41a0-a50e-da0d92984dc7"] = {
    children = {
      "df57a28b-5160-4c0a-97a9-1b23203c64d2"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Ah! Language! The fog, the voices, it must have been this man speaking to you. Could you also speak?",
    uuid = "302c29b4-97a6-41a0-a50e-da0d92984dc7",
    who = "narrator"
  },
  ["437d4130-0408-44b6-90c8-ccdb3aeee13b"] = {
    children = {
      "07c7ec55-b5b1-447b-bb3b-ed2b5c2bd788"
    },
    is_entry_point = false,
    kind = "Set",
    uuid = "437d4130-0408-44b6-90c8-ccdb3aeee13b",
    value = true,
    variable = "intro.tried_to_get_up"
  },
  ["616fe3b4-bdf1-4081-8f48-a56ea3f18ddc"] = {
    children = {},
    is_entry_point = false,
    kind = "Return",
    return_to = "rpt_001",
    uuid = "616fe3b4-bdf1-4081-8f48-a56ea3f18ddc"
  },
  ["665a44bf-ee02-4a80-bf1c-decea08bfbb5"] = {
    branch_on = "intro.heard_language",
    children = {
      "302c29b4-97a6-41a0-a50e-da0d92984dc7",
      "c61fe227-cb24-40f4-88ca-de64bcabf93e"
    },
    is_entry_point = false,
    kind = "Branch",
    uuid = "665a44bf-ee02-4a80-bf1c-decea08bfbb5"
  },
  ["745ec3e3-6ab1-4e40-8355-e22c43b6c419"] = {
    children = {
      "4dd97088-8eae-43fc-b186-ff74588cdaaf"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "He looks at you, clearly puzzled by this question.",
    uuid = "745ec3e3-6ab1-4e40-8355-e22c43b6c419",
    who = "narrator"
  },
  ["761b9e4d-6374-4334-8720-35d648b8b136"] = {
    children = {
      "ce090d7e-802f-4f25-8d09-04fe7f3d6cb3"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "...Hullo!",
    uuid = "761b9e4d-6374-4334-8720-35d648b8b136",
    who = "unknown"
  },
  ["0841e09d-d101-42b8-bec0-e79060c3b23d"] = {
    children = {
      "75ce4d05-1158-45dc-a61f-df7d05e97d85"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "The man who woke you is striking. He said his name was Prism? He's tall -- you can tell he's no freak giant, but he easily would stand six inches above you both standing. Over his right eye, he wears a translucent monocle. It fits his eye as if it were made for him. Over his left, there is a different device. It's entirely opaque -- you're not sure if he can see out of it. And it looks...homemade, somehow. The second device is jacked into the wall with a length from a long cord he keeps looped around his plain coveralls.",
    uuid = "0841e09d-d101-42b8-bec0-e79060c3b23d",
    who = "narrator"
  },
  ["964d129b-d11a-41b3-9622-1e4c74278ddc"] = {
    children = {
      "7d443a7c-e20a-44fd-9abf-b316dac820fc"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You try, by instinct, to move some part of your body, but it's useless. You feel slippery, and nothing on your body has any traction.",
    uuid = "964d129b-d11a-41b3-9622-1e4c74278ddc",
    who = "narrator"
  },
  ["2318feba-b3da-40e0-9346-9b77ec8cbd33"] = {
    children = {
      "8f63ce97-b340-45b3-9222-b353d002968c"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "Why is this guy ignoring an apparent cryorevival patient to collect...something? I should look in the box.",
    uuid = "2318feba-b3da-40e0-9346-9b77ec8cbd33"
  },
  ["2703de97-b712-4428-9ceb-3e322cabea66"] = {
    children = {},
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Okay, seems pretty common. Memory gaps. Lack of institutional knowledge. Well, here it is: The Dome is this place. It is the place that we live. It is all that is and ever will be. We call it the Dome because that's what lies above us. Beyond the Dome, there is nothing. Not even nothing -- it is incomprehensible.",
    uuid = "2703de97-b712-4428-9ceb-3e322cabea66",
    who = "prism"
  },
  ["8324ad4d-e061-4ae7-9f17-716b972b7f56"] = {
    children = {
      "cd49fa8e-a491-4eba-aef9-a6b88a33cb33"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "The light burns your eyes, so you squint them shut. Through your haze of vision, you make out something. A creature? Perhaps. It looks like no living creature you have seen before. It is more fog than man, and you begin to wonder unto what hell you have been born.",
    uuid = "8324ad4d-e061-4ae7-9f17-716b972b7f56",
    who = "mind"
  },
  ["34370ede-88b1-4571-9df3-d1f5f4a00975"] = {
    children = {
      "7fda0c85-d3bd-4279-95c3-36bb359981fb",
      "2c45bc90-90c6-43a4-930f-b6e4f2ace348",
      "00eabd78-7da0-4908-af9a-4446cd004877",
      "3ad2ff15-315e-411c-911e-9a530a1e8a4a",
      "6f6e600b-9ebc-41a1-b6be-8d3dfc7ee631"
    },
    internal_id = "ask_prism",
    is_entry_point = false,
    kind = "ChoiceRepeat",
    uuid = "34370ede-88b1-4571-9df3-d1f5f4a00975"
  },
  ["38730ce5-bbac-4ea2-a664-9069dfc0ab4e"] = {
    children = {
      "2a8b3a7e-afb0-4fcc-aada-3d9b2926f57f"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "...I...",
    uuid = "38730ce5-bbac-4ea2-a664-9069dfc0ab4e",
    who = "unknown"
  },
  ["66708f8d-bdc1-446c-bb52-a534ba732b52"] = {
    children = {
      "1b5c3354-2067-4b4a-8474-2a7496f14641"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You do not know what form you take, but you imagine that you must have a means of motion. You strain without thinking, and intuitively move whatever your eyes are mounted on.",
    uuid = "66708f8d-bdc1-446c-bb52-a534ba732b52",
    who = "narrator"
  },
  ["83986ca8-edac-4202-94ba-9858a160f6e2"] = {
    children = {
      "fb697274-1b9e-47fd-9de7-7ff9e0e281c4"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "Look from your new vantage point.",
    uuid = "83986ca8-edac-4202-94ba-9858a160f6e2"
  },
  ["89413cb6-a409-4d41-bbd3-9053a67d1914"] = {
    children = {
      "0841e09d-d101-42b8-bec0-e79060c3b23d"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You can finally see, hear. Language might be a stretch. You look out to where you are. You're in a cramped room. It is dim, but not dark. The air tastes stale. The walls are plated steel, cobalt blue. Your steel coffin sits attached by grooves onto a track which go into a hole in the back and slowly disappear into black. You're not sure how far they go. ",
    uuid = "89413cb6-a409-4d41-bbd3-9053a67d1914",
    who = "narrator"
  },
  ["141692d1-94a1-4bd7-a314-58e9df1eb7d3"] = {
    branch_on = "intro.tried_to_get_up",
    children = {
      "83986ca8-edac-4202-94ba-9858a160f6e2"
    },
    is_entry_point = false,
    kind = "If",
    uuid = "141692d1-94a1-4bd7-a314-58e9df1eb7d3"
  },
  ["497781df-e718-4f90-b7a4-15f0d6e5fe12"] = {
    children = {
      "8324ad4d-e061-4ae7-9f17-716b972b7f56"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You feel other things bump against you as you rise. You do not know what they are. Light appears in front of you and the ground disgorges you. You lie there, sputtering and flailing -- newborn again.",
    uuid = "497781df-e718-4f90-b7a4-15f0d6e5fe12",
    who = "mind"
  },
  ["680880a5-dc9b-454c-b24d-3da6302c4cd1"] = {
    children = {
      "66708f8d-bdc1-446c-bb52-a534ba732b52"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "Try to look around.",
    uuid = "680880a5-dc9b-454c-b24d-3da6302c4cd1"
  },
  ["942753c6-0f0f-4281-8ef6-0b3cb5463e8c"] = {
    children = {
      "ffe66c6d-418a-4997-8dda-83ae7766c5ab"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "The arms pick you up and lean you against the now-reclined back of your metal table. It happens so quickly that you are stunned, but Prism doesn't even glance your way.",
    uuid = "942753c6-0f0f-4281-8ef6-0b3cb5463e8c",
    who = "narrator"
  },
  ["4897187e-8a72-4403-a4ab-c2aa72d35197"] = {
    children = {
      "f0dfa9a9-ab6a-4f5e-889e-76a2aa92e4d3"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "The height disparity is also clear now -- the other creature is just standing. You're lying on your back on a slightly elevated table inside a stainless steel coffin. The coffin is full of a thin, clear goo. The smell reminds you of something earthen and natural, something ancient. You can see goo slowly dripping off your body and back into the steel box.",
    uuid = "4897187e-8a72-4403-a4ab-c2aa72d35197",
    who = "narrator"
  },
  ["a7fdb55c-d4ae-473e-9726-9f176c4c6ca3"] = {
    children = {
      "39f62dd1-d6a6-4d3f-889b-9729b8dc80f6"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You feel your senses slowly returning to you. The eternal hell of psychic torment that seemed reality mere moments ago now begins to fade like a dream.",
    uuid = "a7fdb55c-d4ae-473e-9726-9f176c4c6ca3",
    who = "unknown"
  },
  ["a11eb829-fd1d-41be-b495-9c5a709fdbe9"] = {
    children = {
      "c6d8ff18-0a2c-41dc-b8aa-b81ca8f4a37e"
    },
    is_entry_point = false,
    kind = "Set",
    uuid = "a11eb829-fd1d-41be-b495-9c5a709fdbe9",
    value = true,
    variable = "intro.heard_language"
  },
  ["a38a636f-81f0-4284-8e5b-fafa35004a5e"] = {
    children = {
      "78fabde2-2d33-461f-8ce3-f837ac78cc39"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Your voice is too feeble. He may hear you, but he's too far in his internal world.",
    uuid = "a38a636f-81f0-4284-8e5b-fafa35004a5e",
    who = "narrator"
  },
  ["a273cb75-765a-4b6a-96b0-9c81b8922998"] = {
    children = {
      "942753c6-0f0f-4281-8ef6-0b3cb5463e8c"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Prism glances at you, and murmurs something. The noise is guttural and unearthly. For some reason, you know that this noise is not meant for you. It is a hellish incantation. Long, spindly arms emerge from the floor. They articulate in ultraprecise, discrete motions. You can barely hear their servos whirring as they actuate. ",
    uuid = "a273cb75-765a-4b6a-96b0-9c81b8922998",
    who = "narrator"
  },
  ["a573f936-87cf-4d74-a8b0-c8e149dc7395"] = {
    children = {
      "27e2d735-2ab6-4032-b45b-f06f301fa7b2"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Sector 576, subsector 8. This is the designated birthing zone. You know, it's really quite rare to be on zone duty when a birthing is scheduled. ",
    uuid = "a573f936-87cf-4d74-a8b0-c8e149dc7395",
    who = "prism"
  },
  ["a730fe2f-6887-4b61-b133-887a680ac1b4"] = {
    children = {
      "e47bea56-5ef0-4fde-a873-8df42c7ff5b8"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "...well, his head turns towards you, but the goggles make it very difficult to tell if he is looking at you. ",
    uuid = "a730fe2f-6887-4b61-b133-887a680ac1b4",
    who = "narrator"
  },
  ["ad8394e4-1f07-4b2b-88bc-a802b90275d2"] = {
    children = {
      "4cf0f09c-a008-4a51-94c7-d895ceb48c54"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Readings looking good -- looks like there may be some light straining, maybe some remnant of cryo paralysis. Let's let him shake it off for a few minutes.",
    uuid = "ad8394e4-1f07-4b2b-88bc-a802b90275d2",
    who = "unknown_waker"
  },
  ["ae350e72-3d05-4fe1-b02a-5df5e127d3aa"] = {
    children = {
      "2703de97-b712-4428-9ceb-3e322cabea66"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "His eye flashes dark again, and he begins to get an abstracted look on his face. He doesn't seem to comprehend your stern face. After a moment, he pops back.",
    uuid = "ae350e72-3d05-4fe1-b02a-5df5e127d3aa",
    who = "narrator"
  },
  ["afc3941c-7f88-45d2-92a8-8d89c4650842"] = {
    children = {
      "b7eff8e0-cc26-475a-96da-4d349309d25b"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "Try to move around",
    uuid = "afc3941c-7f88-45d2-92a8-8d89c4650842"
  },
  ["b7eff8e0-cc26-475a-96da-4d349309d25b"] = {
    branch_on = "intro.has_seen_body",
    children = {
      "437d4130-0408-44b6-90c8-ccdb3aeee13b",
      "964d129b-d11a-41b3-9622-1e4c74278ddc"
    },
    is_entry_point = false,
    kind = "Branch",
    uuid = "b7eff8e0-cc26-475a-96da-4d349309d25b"
  },
  ["b7fa0bdf-8377-4f6d-a0b0-4e20f0ccb6d2"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "You feel self-conscious. Maybe the fabric on the table is clothes? You should check.",
    uuid = "b7fa0bdf-8377-4f6d-a0b0-4e20f0ccb6d2"
  },
  ["b20ae3be-0bd6-43b6-b24c-549d6255136c"] = {
    children = {},
    is_entry_point = false,
    kind = "Return",
    return_to = "rpt_001",
    uuid = "b20ae3be-0bd6-43b6-b24c-549d6255136c"
  },
  ["b092020c-2e5a-440d-a51b-f9fba307b47a"] = {
    children = {
      "e171d140-f6a4-48e3-bca8-890a0be1522c"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You explode from your mortal husk, pulsing out in a wave divorced from any physical form. The fog -- the fog! There is only one way to defeat the fog: Psychic combat. With fonce, go, go!",
    uuid = "b092020c-2e5a-440d-a51b-f9fba307b47a",
    who = "narrator"
  },
  ["bd74e9f0-01ea-4127-ae5e-1ab4d0abc5e7"] = {
    children = {
      "a7fdb55c-d4ae-473e-9726-9f176c4c6ca3"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Wait -- wasn't it a psychic fog? How could a psychic fog enter through my mouth? And what does a psychic fog even mean? ",
    uuid = "bd74e9f0-01ea-4127-ae5e-1ab4d0abc5e7",
    who = "unknown"
  },
  ["c6d8ff18-0a2c-41dc-b8aa-b81ca8f4a37e"] = {
    children = {
      "86dad0f1-f9e8-4e3a-b4ef-aaade4faeb6b"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "O spirit, make known to me your will! Become one with me, such that I may become one with all reality among us, and let me dissolve.",
    uuid = "c6d8ff18-0a2c-41dc-b8aa-b81ca8f4a37e",
    who = "pc"
  },
  ["c61fe227-cb24-40f4-88ca-de64bcabf93e"] = {
    children = {
      "d52a7e4a-984a-412a-bb12-1924316a84e1"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Perhaps your belligerence was unwarranted earlier. Although, who would really do differently when faced with an existential psychic threat? You can faintly remember this strange, goggled man addressing you in your haze.",
    uuid = "c61fe227-cb24-40f4-88ca-de64bcabf93e",
    who = "narrator"
  },
  ["cd49fa8e-a491-4eba-aef9-a6b88a33cb33"] = {
    children = {
      "59db251a-2621-49e7-9895-e407d8f5156e",
      "d0e830b5-155c-4fd8-a7ce-c5793d514f65"
    },
    effects = {
      {
        amplitude = 0.004999999888241291,
        frequency = 59,
        type = 1
      }
    },
    is_entry_point = false,
    kind = "Text",
    text = "...he...llo...? ....me kn....when yo....an hear me...",
    uuid = "cd49fa8e-a491-4eba-aef9-a6b88a33cb33",
    who = "unknown_waker"
  },
  ["ce090d7e-802f-4f25-8d09-04fe7f3d6cb3"] = {
    children = {
      "a730fe2f-6887-4b61-b133-887a680ac1b4"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Prism stops collecting...something...from the tracks that your cryochamber lies on and looks over to you.",
    uuid = "ce090d7e-802f-4f25-8d09-04fe7f3d6cb3",
    who = "narrator"
  },
  ["d0e830b5-155c-4fd8-a7ce-c5793d514f65"] = {
    children = {
      "a11eb829-fd1d-41be-b495-9c5a709fdbe9"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "...language? The fog is speaking to you. This must be God presenting himself to you. You can feel the fog seep into your brain, filling you with light and knowledge, becoming one with you. You must commune with this spirit inside you.",
    uuid = "d0e830b5-155c-4fd8-a7ce-c5793d514f65"
  },
  ["d52a7e4a-984a-412a-bb12-1924316a84e1"] = {
    children = {
      "fb3f621b-5fb0-4586-97ab-7ae1c7a2d1ae",
      "ee68c096-97d5-48e2-9bbb-2dd106eabdbd"
    },
    internal_id = "polite",
    is_entry_point = false,
    kind = "ChoiceRepeat",
    uuid = "d52a7e4a-984a-412a-bb12-1924316a84e1"
  },
  ["d7991ec9-13d9-427d-b6ed-9e6aa3e6e038"] = {
    children = {
      "6fa955b6-71cf-4c39-9828-e5cdf4dadd59"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "The Dome? What is that? ",
    uuid = "d7991ec9-13d9-427d-b6ed-9e6aa3e6e038",
    who = "pc"
  },
  ["d8534f84-ca1e-4597-9a20-fcb42ae4bed8"] = {
    children = {
      "2a8b3a7e-afb0-4fcc-aada-3d9b2926f57f"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Why language? We are one, so why language my Lord? Enter me, send me your message through a beam of light, free me!",
    uuid = "d8534f84-ca1e-4597-9a20-fcb42ae4bed8",
    who = "pc"
  },
  ["dab180b6-63a6-43bf-be7a-35f6d9efe581"] = {
    children = {
      "0fa37749-f1c5-4864-828a-5b93d3a133f7"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "WHAM!",
    uuid = "dab180b6-63a6-43bf-be7a-35f6d9efe581",
    who = "narrator"
  },
  ["df57a28b-5160-4c0a-97a9-1b23203c64d2"] = {
    children = {
      "761b9e4d-6374-4334-8720-35d648b8b136"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Hhh...Huh...hull...ohhh.......",
    uuid = "df57a28b-5160-4c0a-97a9-1b23203c64d2",
    who = "pc"
  },
  ["e3dc89fb-1441-4ef0-8286-03fb80509377"] = {
    children = {
      "34370ede-88b1-4571-9df3-d1f5f4a00975"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "You start to reply, but he's already gone. You still can't see his eyes, but his shoulders go limp, his fingers tap as if on an unseen interface, lips slightly part. Absent. Prism makes you feel uneasy. You're not sure what he is.",
    uuid = "e3dc89fb-1441-4ef0-8286-03fb80509377",
    who = "narrator"
  },
  ["e9c1b8fa-19b1-4644-8cbd-c18e4361c49e"] = {
    branch_on = "intro.woke_prism",
    children = {
      "a573f936-87cf-4d74-a8b0-c8e149dc7395",
      "e5178fec-261b-4ea2-9949-d174d3e80c38"
    },
    is_entry_point = false,
    kind = "Branch",
    uuid = "e9c1b8fa-19b1-4644-8cbd-c18e4361c49e"
  },
  ["e15d10a5-4a44-465d-8558-7f9b0fa49dab"] = {
    children = {
      "bd74e9f0-01ea-4127-ae5e-1ab4d0abc5e7"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "Opening my mouth would allow the fog to enter again.",
    uuid = "e15d10a5-4a44-465d-8558-7f9b0fa49dab"
  },
  ["e47bea56-5ef0-4fde-a873-8df42c7ff5b8"] = {
    children = {
      "e3dc89fb-1441-4ef0-8286-03fb80509377"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Your kind doesn't always pull through, you know. As in living, I mean. We know it's some kind of cryostasis. I could actually pull up the data if you give me a second to make a quick scraper...",
    uuid = "e47bea56-5ef0-4fde-a873-8df42c7ff5b8",
    who = "prism"
  },
  ["e171d140-f6a4-48e3-bca8-890a0be1522c"] = {
    children = {
      "ad8394e4-1f07-4b2b-88bc-a802b90275d2"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "...",
    uuid = "e171d140-f6a4-48e3-bca8-890a0be1522c",
    who = "narrator"
  },
  ["e5178fec-261b-4ea2-9949-d174d3e80c38"] = {
    children = {
      "a38a636f-81f0-4284-8e5b-fafa35004a5e"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Excuse me...?",
    uuid = "e5178fec-261b-4ea2-9949-d174d3e80c38",
    who = "pc"
  },
  ["ee68c096-97d5-48e2-9bbb-2dd106eabdbd"] = {
    branch_on = "intro.fog_is_real",
    children = {
      "e15d10a5-4a44-465d-8558-7f9b0fa49dab"
    },
    is_entry_point = false,
    kind = "If",
    uuid = "ee68c096-97d5-48e2-9bbb-2dd106eabdbd"
  },
  ["f0dfa9a9-ab6a-4f5e-889e-76a2aa92e4d3"] = {
    children = {
      "b20ae3be-0bd6-43b6-b24c-549d6255136c"
    },
    is_entry_point = false,
    kind = "Set",
    uuid = "f0dfa9a9-ab6a-4f5e-889e-76a2aa92e4d3",
    value = true,
    variable = "intro.has_seen_body"
  },
  ["f124cb02-6b59-479a-b130-60ce6ec95360"] = {
    children = {
      "2318feba-b3da-40e0-9346-9b77ec8cbd33",
      "b7fa0bdf-8377-4f6d-a0b0-4e20f0ccb6d2",
      "71b6df16-7fe7-43fd-99cc-ec0a99b6b924",
      "7bf4aa0d-0ffc-4e34-9b96-2970dccc886b"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Inside the hole, you see one the small box that Prism was working with before you awoke. On the table is a smooth, folded piece of fabric, and what looks like a few electronics",
    uuid = "f124cb02-6b59-479a-b130-60ce6ec95360",
    who = "narrator"
  },
  ["fb3f621b-5fb0-4586-97ab-7ae1c7a2d1ae"] = {
    children = {
      "9b12985b-4a88-42b5-bf12-45bce70d2cc5"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "It would be polite to address him, as well.",
    uuid = "fb3f621b-5fb0-4586-97ab-7ae1c7a2d1ae"
  },
  ["fb697274-1b9e-47fd-9de7-7ff9e0e281c4"] = {
    children = {
      "89413cb6-a409-4d41-bbd3-9053a67d1914"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Nearly all of the fog has left your brain. You can feel a familiar feeling that has been absent for a long time. You feel as if there is something separate from your raw sensory input. ",
    uuid = "fb697274-1b9e-47fd-9de7-7ff9e0e281c4",
    who = "narrator"
  },
  ["ffe66c6d-418a-4997-8dda-83ae7766c5ab"] = {
    children = {},
    is_entry_point = false,
    kind = "Return",
    return_to = "rpt_001",
    uuid = "ffe66c6d-418a-4997-8dda-83ae7766c5ab"
  }
}