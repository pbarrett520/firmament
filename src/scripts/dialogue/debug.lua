return {
  ["6f03bb85-5c22-4900-9ac8-4bc1fd6bf40c"] = {
    children = {
      "954f5b67-773b-470d-9226-66288e370b8c",
      "b94b2256-2f3b-437d-9366-0ac496fa80d3"
    },
    is_entry_point = true,
    kind = "Text",
    text = "There are choices after this.",
    uuid = "6f03bb85-5c22-4900-9ac8-4bc1fd6bf40c",
    who = "unknown"
  },
  ["954f5b67-773b-470d-9226-66288e370b8c"] = {
    children = {
      "62708b53-bd5c-4b9a-99ff-389ae8c55c1f"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "This is the first choice.",
    uuid = "954f5b67-773b-470d-9226-66288e370b8c"
  },
  ["17090bdf-8560-4f83-bc8b-bf456699f7d9"] = {
    children = {},
    is_entry_point = false,
    kind = "Switch",
    next_dialogue = "B",
    uuid = "17090bdf-8560-4f83-bc8b-bf456699f7d9"
  },
  ["62708b53-bd5c-4b9a-99ff-389ae8c55c1f"] = {
    children = {},
    is_entry_point = false,
    kind = "Switch",
    next_dialogue = "A",
    uuid = "62708b53-bd5c-4b9a-99ff-389ae8c55c1f"
  },
  ["b94b2256-2f3b-437d-9366-0ac496fa80d3"] = {
    children = {
      "17090bdf-8560-4f83-bc8b-bf456699f7d9"
    },
    is_entry_point = false,
    kind = "Choice",
    text = "This is the second choice.",
    uuid = "b94b2256-2f3b-437d-9366-0ac496fa80d3"
  }
}