return {
  ["0f37165a-b3da-48a9-a0a9-6b6a43128e3a"] = {
    children = {},
    is_entry_point = false,
    kind = "Text",
    text = "False\n",
    uuid = "0f37165a-b3da-48a9-a0a9-6b6a43128e3a",
    who = "unknown"
  },
  ["3fd4b04b-2fc5-433e-bf0d-469c07d4d371"] = {
    children = {
      "21020ad1-307b-4707-90aa-6627fceaf382",
      "242e8ef4-ce81-4487-b5fd-946284d8f1e0"
    },
    is_entry_point = false,
    kind = "Text",
    text = "Nested branches.",
    uuid = "3fd4b04b-2fc5-433e-bf0d-469c07d4d371",
    who = "Nested Branch in Choice"
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
    is_entry_point = true,
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
    is_entry_point = false,
    kind = "Text",
    text = "True",
    uuid = "473398fb-d892-40b1-a216-7a5675458b38",
    who = "unknown"
  },
  ["a8984811-56d7-4e02-b8c9-004281d6aed4"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "False, True",
    uuid = "a8984811-56d7-4e02-b8c9-004281d6aed4"
  },
  ["bd388301-b223-492a-9f1d-f834a6bdc5e5"] = {
    children = {},
    is_entry_point = false,
    kind = "Text",
    text = "The variable is set",
    uuid = "bd388301-b223-492a-9f1d-f834a6bdc5e5",
    who = "unknown"
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