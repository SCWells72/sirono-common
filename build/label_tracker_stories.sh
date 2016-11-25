#!/bin/sh
# set -x
#
#
# set environment and define variables
PROJECT_ID=1608481
PIVOTAL_TOKEN='212c3d7d91c24ad24f5c487ee6a0fcf1'

export_branch_label(){
    BRANCH=`git rev-parse --abbrev-ref HEAD`
    if [ "$BRANCH" == "prod" ]; then
        export BRANCH_LABEL="prod"
    elif [ "$BRANCH" == "qa" ]; then
        export BRANCH_LABEL="qa"
    else
        export BRANCH_LABEL="dev"
    fi
}

get_root_sha(){
    # find the root commit to work from
    ROOT_GIT_SHA=`git log --pretty=format:%H | tail -1`
}

extract_story_ids() {
  REV1="$1"
  REV2="$2"

  # format is:
  #   '[#nnnnnn]
  STORY_IDS=`git log ${REV1}..${REV2} --grep='#[0-9]\+' --no-merges --pretty=format:%B \
    | python -c 'import re,sys;r=re.compile("#([0-9]+)");print "\n".join(r.findall(sys.stdin.read()))' \
    | uniq`
  echo "$STORY_IDS"
}

label_tracker_stories(){
  for id in `extract_story_ids ${ROOT_GIT_SHA} HEAD`; do
      if [ ${#id} -ge 8 ]
        then
            LABELS=`curl -X GET -H "X-TrackerToken: $PIVOTAL_TOKEN" -H "Content-Type: application/json" "https://www.pivotaltracker.com/services/v5/stories/$id?fields=labels" \
            | python -c 'import os,json,sys;obj=sys.stdin.read();label_json=json.loads(obj);l_set=set(map((lambda x: x["name"]), label_json["labels"]));l_set.add("on_{}".format(os.getenv("BRANCH_LABEL")));print("{{\"labels\": {}}}".format(json.dumps(list(l_set))));'`

            curl -X PUT -H "X-TrackerToken: $PIVOTAL_TOKEN" -H "Content-Type: application/json" -d "$LABELS" "https://www.pivotaltracker.com/services/v5/stories/$id"
      fi
  done
}

#
## Main
#
get_root_sha
export_branch_label
label_tracker_stories