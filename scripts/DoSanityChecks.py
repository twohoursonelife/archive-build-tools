#!/usr/bin/env python

import os
import re
import sys


## Constants

ROOT_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
DATA_DIR = os.path.join(ROOT_DIR, 'repos', 'crucible-data')
SPRITES_DIR = os.path.join(DATA_DIR, 'sprites')
SOUNDS_DIR = os.path.join(DATA_DIR, 'sounds')
OBJECTS_DIR = os.path.join(DATA_DIR, 'objects')
CATEGORIES_DIR = os.path.join(DATA_DIR, 'categories')
ANIMATIONS_DIR = os.path.join(DATA_DIR, 'animations')
TRANSITIONS_DIR = os.path.join(DATA_DIR, 'transitions')


## Error Tracking

exit_status = 0

def error(message):
    global exit_status
    print(message)
    exit_status = 1


## Sprites

found_sprite_ids = set()
used_sprite_ids = set()
for sprite_file_name in os.listdir(SPRITES_DIR):
    sprite_file_match = re.match(r'^(-?[0-9]+)\.txt$', sprite_file_name)
    if sprite_file_match is not None:
        sprite_id = int(sprite_file_match.group(1))
        if not os.path.exists(os.path.join(SPRITES_DIR, f'{sprite_id}.tga')):
            error(f'sprite {sprite_id} has not .tga file')
            exit_status = 1
        else:
            found_sprite_ids.add(sprite_id)
for sprite_file_name in os.listdir(SPRITES_DIR):
    sprite_file_match = re.match(r'^(-?[0-9]+)\.tga$', sprite_file_name)
    if sprite_file_match is not None:
        sprite_id = int(sprite_file_match.group(1))
        if sprite_id not in found_sprite_ids:
            error(f'sprite {sprite_id} has not .tga file')


## Sounds

found_sound_ids = set()
used_sound_ids = set()
for sound_file_name in os.listdir(SOUNDS_DIR):
    sound_file_match = re.match(r'^(-?[0-9]+)\.aiff$', sound_file_name)
    if sound_file_match is not None:
        sound_id = int(sound_file_match.group(1))
        found_sound_ids.add(sound_id)


## Objects

found_object_ids = set()
for object_file_name in os.listdir(OBJECTS_DIR):
    object_file_match = re.match(r'^(-?[0-9]+)\.txt$', object_file_name)
    if object_file_match is not None:
        object_id = int(object_file_match.group(1))
        found_object_ids.add(object_id)
        object_data = open(os.path.join(OBJECTS_DIR, object_file_name)).read()
        for sprite_id_string in re.findall(r'(?m)^spriteID=([0-9]+)$', object_data):
            sprite_id = int(sprite_id_string)
            if sprite_id not in found_sprite_ids:
                error(f'object ({object_id}) contains missing sprite ({sprite_id})')
            else:
                used_sprite_ids.add(sprite_id)
        sound_data_match = re.search(r'(?m)^sounds=(.*)$', object_data)
        if sound_data_match is not None:
            for sound_data in sound_data_match.group(1).split(','):
                for partial_sound_data in sound_data.split('#'):
                    sound_id = int(partial_sound_data.split(':')[0])
                    if sound_id > 0 and sound_id not in found_sound_ids:
                        error(f'object ({object_id}) contains missing sound ({sound_id})')
                    else:
                        used_sound_ids.add(sound_id)


## Categories

for category_file_name in os.listdir(CATEGORIES_DIR):
    category_file_match = re.match(r'^([0-9]+)\.txt$', category_file_name)
    if category_file_match is not None:
        category_id = int(category_file_match.group(1))
        category_data = open(os.path.join(CATEGORIES_DIR, category_file_name)).read()
        parent_id_string = re.search(r'(?m)^parentID=([0-9]+)', category_data).group(1)
        parent_id = int(parent_id_string)
        if parent_id not in found_object_ids:
            errory(f'category ({category_id}) contains missing object ({parent_id})')
        if parent_id != category_id:
            error(f'category ({category_id}) does not match object ({parent_id})')
        num_objects_string = re.search(r'(?m)^numObjects=([0-9]+)', category_data).group(1)
        num_objects = int(num_objects_string)
        object_count = len(re.findall(r'(?m)^([0-9]+)', category_data))
        if num_objects != object_count:
            error(f'category ({category_id}) has incorrect object count ({num_objects} ≠ {object_count})')


## Animations

for animation_file_name in os.listdir(ANIMATIONS_DIR):
    animation_file_match = re.match(r'^(-?[0-9]+)_(-?[0-9]+)(?:x[0-9]+)?\.txt$', animation_file_name)
    if animation_file_match is not None:
        object_id = int(animation_file_match.group(1))
        animation_type = int(animation_file_match.group(2))
        if object_id > 0 and object_id not in found_object_ids:
            error(f'animation ({animation_file_name[:-4]}) contains missing object ({object_id})')
        animation_data = open(os.path.join(ANIMATIONS_DIR, animation_file_name)).read()
        for sound_data in re.findall(r'(?m)^soundParam=(\S*)', animation_data):
            for partial_sound_data in sound_data.split('#'):
                sound_id = int(partial_sound_data.split(':')[0])
                if sound_id > 0 and sound_id not in found_sound_ids:
                    error(f'animation ({animation_file_name[:-4]}) contains missing sound ({sound_id})')
                else:
                    used_sound_ids.add(sound_id)


## Transitions

for transition_file_name in os.listdir(TRANSITIONS_DIR):
    transition_file_match = re.match(r'^(-?[0-9]+)_(-?[0-9]+)(?:_LT|_LA)?\.txt$', transition_file_name)
    if transition_file_match is not None:
        actor_id, target_id = map(int, transition_file_match.groups())
        if actor_id > 0 and actor_id not in found_object_ids:
            error(f'transition ({transition_file_name[:-4]}) contains missing object ({actor_id}) as actor')
        if target_id > 0 and target_id not in found_object_ids:
            error(f'transition ({transition_file_name[:-4]}) contains missing object ({target_id}) as target')
        transition_data = open(os.path.join(TRANSITIONS_DIR, transition_file_name)).read()
        new_actor_id, new_target_id = map(int, transition_data.split()[:2])
        if new_actor_id > 0 and new_actor_id not in found_object_ids:
            error(f'transition ({transition_file_name[:-4]}) contains missing object ({new_actor_id}) as new actor')
        if new_target_id > 0 and new_target_id not in found_object_ids:
            error(f'transition ({transition_file_name[:-4]}) contains missing object ({new_target_id}) as new target')


## Reverse Sprites

if 'reverse_check' in sys.argv:
    for sprite_id in found_sprite_ids - used_sprite_ids:
        error(f'sprite ({sprite_id}) not used by any object')


## Reverse Sounds

if 'reverse_check' in sys.argv:
    for sound_id in found_sound_ids - used_sound_ids:
        error(f'sound ({sound_id}) not used by any object or animation')


## Exit

sys.exit(exit_status)