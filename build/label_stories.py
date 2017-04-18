import os, subprocess, re, requests, argparse, json

SF_PROJECT_ID = 1608481
PORTAL_PROJECT_ID = 1930765
PIVOTAL_TOKEN = '212c3d7d91c24ad24f5c487ee6a0fcf1'
HEADERS = {"X-TrackerToken": PIVOTAL_TOKEN, "Content-type": "application/json"}
TRACKER_STORY_URL = "https://www.pivotaltracker.com/services/v5/projects/{}/stories/{}"

CURRENT_STATE = "current_state"

state_hierarchy = {
    'finished': 1,
    'delivered': 2,
    'accepted': 3
}

branch_state_map = {
    'master': 'finished',
    'qa': 'delivered',
    'prod': 'accepted'
}

branch_label_map = {
    'master': 'on_dev',
    'qa': 'on_qa',
    'prod': 'on_prod'
}


def get_story_ids():
    unique_story_ids = set()
    r = re.compile("#([0-9]+)")
    p = subprocess.Popen("git log HEAD --no-merges |grep '#[0-9]\+'|grep '\['", shell=True,
                         stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

    for line in p.stdout.readlines():
        stories = r.findall(line)
        if stories:
            for s_id in stories:
                if len(s_id) > 7: unique_story_ids.add(s_id)

    # print "\n".join(unique_story_ids)
    return unique_story_ids


def get_branch_label(current_branch):
    return branch_label_map[current_branch]


def get_project_id(current_branch):
    if 'portal' == current_branch:
        return PORTAL_PROJECT_ID
    return SF_PROJECT_ID


def get_story(project_id, tracker_id):
    try:
        get_url = TRACKER_STORY_URL.format(project_id, tracker_id)
        response = requests.get(get_url, headers=HEADERS)
        response.raise_for_status()
    except requests.exceptions.HTTPError as fourOfour:
        if response.status_code == 404:
            if project_id == SF_PROJECT_ID:
                return get_story(PORTAL_PROJECT_ID, tracker_id)
            else:
                return None
    except requests.exceptions.RequestException as e:
        print e
        return None

    return response.json()


def update_story(current_branch, story_json):

    story_id = story_json["id"]
    project_id = story_json["project_id"]
    branch_label = get_branch_label(current_branch)

    request_body = dict()
    label_set = set(map((lambda x: x["name"]), story_json["labels"]))

    if 'rejected' != story_json[CURRENT_STATE].lower():
        if not branch_label in label_set:
            print("Add label: {} to story: {} ".format(branch_label, story_id))
            label_set.add(branch_label)
            request_body["labels"] = list(map((lambda x: {"name": x}), label_set))

        if 'unscheduled' != story_json[CURRENT_STATE].lower():
            if state_hierarchy[branch_state_map[current_branch]] > state_hierarchy.get(story_json[CURRENT_STATE], 0):
                new_state = branch_state_map[current_branch]
                if 'chore' == story_json['story_type'].lower() and story_json[CURRENT_STATE].lower() == 'started':
                    new_state = 'accepted'
                print("Update state for story: {} from: {} to: {}".format(story_id, story_json[CURRENT_STATE], new_state))

                request_body[CURRENT_STATE] = new_state

        if request_body:
            if project_id == PORTAL_PROJECT_ID and 'chore' == story_json['story_type'].lower():
                if 'estimate' not in story_json:
                    request_body['estimate'] = 1

        if request_body:
            # print('\nstory retrieved: '+ json.dumps(story_json))
            # print('\nstory to push: '+ json.dumps(request_body))
            response = requests.put(TRACKER_STORY_URL.format(project_id, story_id), json=request_body, headers=HEADERS)
            response.raise_for_status()


def main():
    parser = argparse.ArgumentParser(description="Label tracker stories in the given branch & update their current state")
    parser.add_argument('-b', '--branch', dest="current_branch", required=True)
    args = parser.parse_args()

    if args.current_branch:
        if branch_label_map.has_key(args.current_branch):
            print('Updating tracker stories addressed in branch: {}'.format(args.current_branch))
            for story_id in get_story_ids():
                story_json = get_story(SF_PROJECT_ID, story_id)

                if story_json:
                    update_story(args.current_branch, story_json)
        else:
            print('Only able to process branches: {}. Please change your branch and try again'.format(', '.join(branch_label_map.keys())))
    else:
        print('Unable to determine the current branch')

if __name__ == '__main__':
    main()
