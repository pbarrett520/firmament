return {
  ["0f37165a-b3da-48a9-a0a9-6b6a43128e3a"] = {
    children = {},
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "False\n",
    uuid = "0f37165a-b3da-48a9-a0a9-6b6a43128e3a",
    who = "unknown"
  },
  ["2bfee651-93e9-4b67-933c-753e4d1d83e8"] = {
    children = {
      "44674632-bc99-41a1-9ed5-90a57eb70b20",
      "a8e81273-02a4-44b0-b1b4-bfe25ed941de",
      "dfed8a48-5161-4e44-8178-f7432f4ffeaa"
    },
    internal_id = "if_nodes",
    is_entry_point = false,
    kind = "ChoiceRepeat",
    uuid = "2bfee651-93e9-4b67-933c-753e4d1d83e8"
  },
  ["3fd4b04b-2fc5-433e-bf0d-469c07d4d371"] = {
    children = {
      "21020ad1-307b-4707-90aa-6627fceaf382",
      "242e8ef4-ce81-4487-b5fd-946284d8f1e0"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Nested branches, but also Patrick rulez.",
    uuid = "3fd4b04b-2fc5-433e-bf0d-469c07d4d371",
    who = "Nested Branch in Choice"
  },
  ["4b9b0798-7d6f-4a1a-a43b-37e5205e514d"] = {
    children = {},
    is_entry_point = false,
    kind = "Return",
    return_to = "if_nodes",
    uuid = "4b9b0798-7d6f-4a1a-a43b-37e5205e514d"
  },
  ["4e6d1cd9-34ae-440e-8bce-e84e6aba7905"] = {
    branch_on = "engine.branch",
    children = {
      "473398fb-d892-40b1-a216-7a5675458b38",
      "0f37165a-b3da-48a9-a0a9-6b6a43128e3a"
    },
    is_entry_point = false,
    kind = "Branch",
    uuid = "4e6d1cd9-34ae-440e-8bce-e84e6aba7905"
  },
  ["05a40a8b-06da-47f9-8430-66d4dd118721"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "True, True",
    uuid = "05a40a8b-06da-47f9-8430-66d4dd118721"
  },
  ["6f03bb85-5c22-4900-9ac8-4bc1fd6bf40c"] = {
    children = {
      "22f6aa31-4a79-487c-8f6f-03829512c6a7"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "This will set engine.set_me",
    uuid = "6f03bb85-5c22-4900-9ac8-4bc1fd6bf40c",
    who = "Set State"
  },
  ["22f6aa31-4a79-487c-8f6f-03829512c6a7"] = {
    children = {
      "bd388301-b223-492a-9f1d-f834a6bdc5e5"
    },
    is_entry_point = false,
    kind = "Set",
    uuid = "22f6aa31-4a79-487c-8f6f-03829512c6a7",
    value = true,
    variable = "engine.set_me"
  },
  ["84d6edbd-f45a-494b-85c9-8d280d1a001d"] = {
    children = {
      "4e6d1cd9-34ae-440e-8bce-e84e6aba7905"
    },
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "Basic Branch",
    uuid = "84d6edbd-f45a-494b-85c9-8d280d1a001d",
    who = "Basic Branch"
  },
  ["242e8ef4-ce81-4487-b5fd-946284d8f1e0"] = {
    branch_on = "engine.branch",
    children = {
      "ffbc5c5a-c228-4e91-85bf-511ad3c1706c",
      "323a7861-2815-476b-899d-30d4154adc52"
    },
    is_entry_point = false,
    kind = "Branch",
    uuid = "242e8ef4-ce81-4487-b5fd-946284d8f1e0"
  },
  ["272bb10a-92c9-455e-804b-8f61be3cc8c5"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "True, False",
    uuid = "272bb10a-92c9-455e-804b-8f61be3cc8c5"
  },
  ["323a7861-2815-476b-899d-30d4154adc52"] = {
    branch_on = "engine.branch2",
    children = {
      "a8984811-56d7-4e02-b8c9-004281d6aed4",
      "75471b18-eea7-44ec-b42c-424d508ecc56"
    },
    is_entry_point = false,
    kind = "Branch",
    uuid = "323a7861-2815-476b-899d-30d4154adc52"
  },
  ["21020ad1-307b-4707-90aa-6627fceaf382"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "You always get this choice",
    uuid = "21020ad1-307b-4707-90aa-6627fceaf382"
  },
  ["75471b18-eea7-44ec-b42c-424d508ecc56"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "False, False",
    uuid = "75471b18-eea7-44ec-b42c-424d508ecc56"
  },
  ["473398fb-d892-40b1-a216-7a5675458b38"] = {
    children = {},
    effects = {},
    is_entry_point = false,
    kind = "Text",
    text = "True",
    uuid = "473398fb-d892-40b1-a216-7a5675458b38",
    who = "unknown"
  },
  ["44674632-bc99-41a1-9ed5-90a57eb70b20"] = {
    children = {
      "4b9b0798-7d6f-4a1a-a43b-37e5205e514d"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "You always see this one.",
    uuid = "44674632-bc99-41a1-9ed5-90a57eb70b20"
  },
  ["a8e81273-02a4-44b0-b1b4-bfe25ed941de"] = {
    children = {
      "4b9b0798-7d6f-4a1a-a43b-37e5205e514d"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "You always see this one too",
    uuid = "a8e81273-02a4-44b0-b1b4-bfe25ed941de"
  },
  ["a8984811-56d7-4e02-b8c9-004281d6aed4"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "False, True",
    uuid = "a8984811-56d7-4e02-b8c9-004281d6aed4"
  },
  ["aff39874-1503-479f-bca5-4b79c62856fb"] = {
    children = {
      "2bfee651-93e9-4b67-933c-753e4d1d83e8"
    },
    effects = {},
    is_entry_point = true,
    kind = "Text",
    text = "Toggle examples.if_nodes to be true, and then run this dialogue. When it's true, you will get the third choice.",
    uuid = "aff39874-1503-479f-bca5-4b79c62856fb",
    who = "If Nodes"
  },
  ["b2955f41-721c-48a9-956e-9863345f9274"] = {
    children = {
      "4b9b0798-7d6f-4a1a-a43b-37e5205e514d"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "Toggle examples.if_nodes to be true",
    uuid = "b2955f41-721c-48a9-956e-9863345f9274"
  },
  ["bd388301-b223-492a-9f1d-f834a6bdc5e5"] = {
    children = {},
    is_entry_point = false,
    kind = "Text",
    text = "The variable is set",
    uuid = "bd388301-b223-492a-9f1d-f834a6bdc5e5",
    who = "unknown"
  },
  ["dfed8a48-5161-4e44-8178-f7432f4ffeaa"] = {
    branch_on = "examples.if_node",
    children = {
      "b2955f41-721c-48a9-956e-9863345f9274"
    },
    is_entry_point = false,
    kind = "If",
    uuid = "dfed8a48-5161-4e44-8178-f7432f4ffeaa"
  },
  ["ffbc5c5a-c228-4e91-85bf-511ad3c1706c"] = {
    branch_on = "engine.branch1",
    children = {
      "05a40a8b-06da-47f9-8430-66d4dd118721",
      "272bb10a-92c9-455e-804b-8f61be3cc8c5"
    },
    is_entry_point = false,
    kind = "Branch",
    uuid = "ffbc5c5a-c228-4e91-85bf-511ad3c1706c"
  }
}