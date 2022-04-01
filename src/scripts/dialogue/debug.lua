return {
  ["05a40a8b-06da-47f9-8430-66d4dd118721"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "True, True",
    uuid = "05a40a8b-06da-47f9-8430-66d4dd118721"
  },
  ["6f03bb85-5c22-4900-9ac8-4bc1fd6bf40c"] = {
    children = {
      "242e8ef4-ce81-4487-b5fd-946284d8f1e0",
      "21020ad1-307b-4707-90aa-6627fceaf382"
    },
    is_entry_point = true,
    kind = "Text",
    text = "There are choices after this.",
    uuid = "6f03bb85-5c22-4900-9ac8-4bc1fd6bf40c",
    who = "unknown"
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
  ["a8984811-56d7-4e02-b8c9-004281d6aed4"] = {
    children = {},
    is_entry_point = false,
    kind = "Choice",
    text = "False, True",
    uuid = "a8984811-56d7-4e02-b8c9-004281d6aed4"
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