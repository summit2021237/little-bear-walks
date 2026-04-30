# Config File
The `config.json` file should be located in the `config` directory. See [`config_example.json`](https://github.com/summit2021237/little-bear-walks/blob/main/documentation/config_example.json) in the `documentation` directory for a complete example. The JSON object has three fields with names `walk_info`, `people`, and `other_model_values`.

## `walk_info`
This field is an object with fields
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
This field is an array of objects with fields
- `time`: The name of the walk time
- `duration`: The duration of the walk at `time` in minutes

Example:
```
{
    "time": "Morning",
    "duration": 30
}
```

### `walk_not_needed`
This field is an array of objects with fields
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
This field is an array of objects describing people to assign to walks with fields
- `name`: The person's name
- `ratings_file`: The name of the CSV file that the person's walk ratings are in
  - The ratings file should be in the `data` directory
- `walk_event_info`: An object with fields for each walk time describing how that person's calendar events should be created
- `max_walk_amount`: An optional field describing the maximum percentage of the total duration of the walks that person can have (see `evenly_distribute` from [`other_model_values`](#other_model_values))

Example:
```
{
    "name": "Person",
    "ratings_file": "2026_january_person.csv",
    "walk_event_info": []
}
```

### `walk_event_info`
This is an object with fields relating each walk time (lowercase name of the walk time) to an object describing calendar event info with fields
- `time`: The name of the walk time that this calendar event info is for
- `event_name`: What the calendar event should be called
- `event_time`: When the calendar event should be scheduled for, formatted as `HH:MM`

Example:
```
{
    "morning": {
        "time": "Morning",
        "event_name": "Walk 🐕",
        "event_time": "06:30"
    }
}
```

## `other_model_values`
This field is an object with fields
- `evenly_distribute`: `true` if each person should be assigned to roughly the same total duration of walk time, `false` otherwise
  - If `false`, each object in the `people` array must have another field `max_walk_amount` describing the maximum percentage of the total duration of the walks the person can have
- `all_walk_multiplier`: Multiplier to decrease the possibility of one person being assigned to all the walks for a day
  - $A$ in the objective function,

$$\sum_{t\in T}\sum_{d\in D}\sum_{p\in P}r_{t,d,p}w_{t,d}x_{t,d,p}-A\sum_{p\in P}\sum_{d\in D}y_{d,p}\text{,}$$

with  
$\quad$ $T$ being the set of walk times,  
$\quad$ $D$ being the set of dates,  
$\quad$ $P$ being the set of people,  
$\quad$ $r_{t,d,p}$ being person $p$'s rating for the walk on date $d$ at time $t$  
$\quad$ $w_{t,d}=1$ if a walk is needed for date $d$ and time $t$ and $w_{t,d}=0$ otherwise  
$\quad$ $A$ being `all_walk_multiplier`, and  
$\quad$ $y_{d,p}=1$ if person $p$ is assigned to all the walk times on date $d$ and $y_{d,p}=0$ otherwise.

Example:
```
{
    "evenly_distribute": true,
    "all_walk_multiplier": 7.5
}
```
