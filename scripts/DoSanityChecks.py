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
TRANSITIONS_DIR = os.path.join(DATA_DIR, 'transitions')


## Error Tracking

exit_status = 0

def error(message):
    global exit_status
    print(message)
    exit_status = 1


## Sprites

found_sprite_ids = set()
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
        sound_data_match = re.match(r'(?m)^sounds=(.*)$', object_data)
        if sound_data_match is not None:
            for sound_data in sound_data_match.group(1).split(','):
                for partial_sound_data in sound_data.split('#'):
                    sound_id = int(partial_sound_data.split(':')[0])
                    if sound_id > 0 and sound_id not in found_sound_ids:
                        error(f'object ({object_id}) contains missing sound ({sound_id})')


## Transitions

for transition_file_name in os.listdir(TRANSITIONS_DIR):
    transition_file_match = re.match(r'^(-?[0-9]+)_(-?[0-9]+)(?:_LT|_LA)?\.txt$', transition_file_name)
    if transition_file_match is not None:
        actor_id, target_id = map(int, transition_file_match.groups())
        transition_file_path = os.path.join(TRANSITIONS_DIR, transition_file_name)
        new_actor_id, new_target_id = map(int, open(transition_file_path).read().split()[:2])
        if actor_id > 0 and actor_id not in found_object_ids:
            error(f'transition ({transition_file_name[:-4]}) contains missing object ({actor_id}) as actor')
        if target_id > 0 and target_id not in found_object_ids:
            error(f'transition ({transition_file_name[:-4]}) contains missing object ({target_id}) as target')
        if new_actor_id > 0 and new_actor_id not in found_object_ids:
            error(f'transition ({transition_file_name[:-4]}) contains missing object ({new_actor_id}) as new actor')
        if new_target_id > 0 and new_target_id not in found_object_ids:
            error(f'transition ({transition_file_name[:-4]}) contains missing object ({new_target_id}) as new target')


## Exit

sys.exit(exit_status)