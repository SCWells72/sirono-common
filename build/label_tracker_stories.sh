#!/bin/sh
# set -x
#
#
# set environment and define variables
PROJECT_ID=1608481
PIVOTAL_TOKEN='212c3d7d91c24ad24f5c487ee6a0fcf1'

get_current_branch(){
    CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD`
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
            if [ "$CURRENT_BRANCH" == "prod" ]; then
                curl -X PUT -H "X-TrackerToken: $PIVOTAL_TOKEN" -H "Content-Type: application/json" -d '{"labels":["on_prod"]}' "https://www.pivotaltracker.com/services/v5/stories/$id"
            elif [ "$CURRENT_BRANCH" == "qa" ]; then
                curl -X PUT -H "X-TrackerToken: $PIVOTAL_TOKEN" -H "Content-Type: application/json" -d '{"labels":["on_qa"]}' "https://www.pivotaltracker.com/services/v5/stories/$id"
            else
                curl -X PUT -H "X-TrackerToken: $PIVOTAL_TOKEN" -H "Content-Type: application/json" -d '{"labels":["on_dev"]}' "https://www.pivotaltracker.com/services/v5/stories/$id"
            fi
      fi
  done
}

#
## Main
#
get_root_sha
get_current_branch
label_tracker_stories

