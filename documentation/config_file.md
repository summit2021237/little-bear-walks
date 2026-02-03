# Config File
The `config.json` file should be located in the `config` directory. See `config_example.json` in the `documentation` directory for a complete example. The JSON object has three fields with names `walk_info`, `people`, and `other_model_values`.

## `walk_info`
This field is an object with
- `walks`: An array of objects describing walk times
- `start_date`: The start date for assigning walks, formatted as `MM/DD/YYYY`
- `end_date`: The end date for assigning walks, formatted as `MM/DD/YYYY`
- `walk_not_needed`: An array of objects describing walk times not needed for each date

Example:
```
{
    "walks": [],
    "start_date": "01/01/2026",
    "end_date": "01/31/2026",
    "walk_not_needed": []
}
```

### `walks`
This field is an array of objects with
- `time`: The name of the walk time
- `duration`: The duration of the walk at `time`
  - Units do not matter but should be the same for each object in `walks`

Example:
```
{
    "time": "Morning",
    "duration": 1
}
```

### `walk_not_needed`
This field is an array of objects with
- `date`: The date where at least one walk time is not needed
- `times`: An array of the walk times that are not needed

Example:
```
{
    "date": "01/02/2026",
    "times": ["Morning"]
}
```

## `people`
This field is an array of objects describing people to assign to walks with
- `name`: The person's name
- `ratings_file`: The name of the CSV file that the person's walk ratings are in
  - The ratings file should be in the `data` directory
- `walk_event_info`: An array of objects describing how that person's calendar events should be created
- `max_walk_portion`: An optional field describing the maximum percentage of the total duration of the walks that person can have (see `evenly_distribute` from [`other_model_values`](#other_model_values))

Example:
```
{
    "name": "Person",
    "ratings_file": "2026_january_person.csv",
    "walk_event_info": []
}
```

### `walk_event_info`
This field is an array of objects for each walk time with
- `time`: The name of the walk time that this calendar event info is for
- `event_name`: What the calendar event should be called
- `event_time`: When the calendar event should be scheduled for, formatted as `HH:MM`

Example:
```
{
    "time": "Morning",
    "event_name": "Walk 🐕",
    "event_time": "06:30"
}
```

## `other_model_values`
This field is an object with fields
- `evenly_distribute`: `true` if each person should be assigned to roughly the same total duration of walk time, `false` otherwise
  - If `false`, each object in the `people` array must have another field `max_walk_portion` describing the maximum percentage of the total duration of the walks the person can have
- `all_walk_multiplier`: Multiplier to decrease the possibility of one person being assigned to all the walks for a day
  - *<TODO: var name>* in the function to maximize, <TODO: write the function on a new line and centered>

Example:
```
{
    "evenly_distribute": true,
    "all_walk_multiplier": 7.5
}
```
