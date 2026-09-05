# Shared prompt data. This file is sourced by the Bash and Zsh renderers.

_shelltone_git_clear() {
  _stg_branch='' _stg_upstream='' _stg_action=''
  _stg_ahead=0 _stg_behind=0 _stg_push_ahead=0 _stg_push_behind=0
  _stg_staged=0 _stg_changed=0 _stg_untracked=0 _stg_conflicted=0
  _stg_deleted=0 _stg_renamed=0 _stg_stashes=0
  _stg_added=0 _stg_modified=0
}

_shelltone_git_collect() {
  local data line xy gitdir counts push_ref oid='' scan=normal
  _shelltone_git_clear
  [[ ${SHELLTONE_SHOW_GIT:-true} == true ]] || return 0
  [[ ${SHELLTONE_GIT_UNTRACKED:-true} == true ]] || scan=no
  # One status snapshot provides branch, movement, stash and file state.
  # Never refresh the user's index or take its optional lock from a prompt.
  data=$(GIT_OPTIONAL_LOCKS=0 command git status --porcelain=v2 --branch --show-stash --untracked-files="$scan" 2>/dev/null) || return 0
  while IFS= read -r line; do
    case $line in
      '# branch.oid '*) oid=${line#\# branch.oid } ;;
      '# branch.head '*) _stg_branch=${line#\# branch.head } ;;
      '# branch.upstream '*) _stg_upstream=${line#\# branch.upstream } ;;
      '# branch.ab '*) counts=${line#\# branch.ab +}; _stg_ahead=${counts%% *}; _stg_behind=${counts##* -} ;;
      '# stash '*) _stg_stashes=${line#\# stash } ;;
      'u '*) _stg_conflicted=$((_stg_conflicted + 1)) ;;
      '? '*) _stg_untracked=$((_stg_untracked + 1)) ;;
      '1 '*|'2 '*)
        xy=${line#??}; xy=${xy%% *}
        case $xy in [!.]?) _stg_staged=$((_stg_staged + 1));; esac
        case $xy in ?[!.]) _stg_changed=$((_stg_changed + 1));; esac
        case $xy in *D*) _stg_deleted=$((_stg_deleted + 1));; esac
        case $xy in *R*) _stg_renamed=$((_stg_renamed + 1));; esac
        case $xy in A.) _stg_added=1;; esac
        case $xy in M.|MM|.M|AM|.T) _stg_modified=1;; esac
        ;;
    esac
    if [[ ${SHELLTONE_GIT_DETAIL:-true} != true ]] && (( _stg_staged + _stg_changed + _stg_untracked + _stg_conflicted > 0 )); then
      break
    fi
  done <<EOF
$data
EOF
  [[ $_stg_branch != '(detached)' ]] || _stg_branch="@${oid:0:7}"
  gitdir=$(command git rev-parse --absolute-git-dir 2>/dev/null) || return 0
  if [[ -d $gitdir/rebase-merge || -d $gitdir/rebase-apply ]]; then
    _stg_action=rebase
  elif [[ -f $gitdir/MERGE_HEAD ]]; then _stg_action=merge
  elif [[ -f $gitdir/CHERRY_PICK_HEAD ]]; then _stg_action=cherry-pick
  elif [[ -f $gitdir/REVERT_HEAD ]]; then _stg_action=revert
  elif [[ -f $gitdir/BISECT_LOG ]]; then _stg_action=bisect
  fi
  if [[ ${SHELLTONE_GIT_DETAIL:-true} == true && ${SHELLTONE_GIT_LABEL_STYLE:-standard} != purity ]]; then
    push_ref=$(command git rev-parse --symbolic-full-name '@{push}' 2>/dev/null) || push_ref=''
    if [[ -n $push_ref && $push_ref != "refs/remotes/$_stg_upstream" && $push_ref != "refs/heads/$_stg_upstream" ]]; then
      counts=$(command git rev-list --left-right --count '@{push}...HEAD' 2>/dev/null) || counts=''
      if [[ -n $counts ]]; then _stg_push_behind=${counts%%[[:space:]]*}; _stg_push_ahead=${counts##*[[:space:]]}; fi
    fi
  fi
  return 0
}

# A fixed, newline-delimited protocol carries data, never shell code. Git ref
# names cannot contain newlines; the root path is not sent across the pipe.
_shelltone_git_write() {
  printf '%s\n' "$_stg_branch" "$_stg_upstream" "$_stg_action" \
    "$_stg_ahead" "$_stg_behind" "$_stg_push_ahead" "$_stg_push_behind" \
    "$_stg_staged" "$_stg_changed" "$_stg_untracked" "$_stg_conflicted" \
    "$_stg_deleted" "$_stg_renamed" "$_stg_stashes" "$_stg_added" "$_stg_modified"
}

_shelltone_git_read() {
  local key
  for key in _stg_branch _stg_upstream _stg_action _stg_ahead _stg_behind \
    _stg_push_ahead _stg_push_behind _stg_staged _stg_changed _stg_untracked \
    _stg_conflicted _stg_deleted _stg_renamed _stg_stashes _stg_added _stg_modified; do
    IFS= read -r "$key" || { _shelltone_git_clear; return 1; }
  done
}

_shelltone_git_segments() {
  [[ -n $_stg_branch ]] || return 1
  local prefix='' n label
  if [[ ${SHELLTONE_GIT_LABEL_STYLE:-standard} == purity ]]; then
    _shelltone_git_segment "$SHELLTONE_GIT_PREFIX_FG" git
    _shelltone_git_segment "$SHELLTONE_GIT_COLON_FG" :
    _shelltone_git_segment "$SHELLTONE_GIT_BRANCH_FG" "$_stg_branch"
    (( _stg_added > 0 )) && _shelltone_git_segment 2 '✓'
    (( _stg_modified > 0 )) && _shelltone_git_segment 4 '✶'
    (( _stg_deleted > 0 )) && _shelltone_git_segment 1 '✗'
    (( _stg_renamed > 0 )) && _shelltone_git_segment 5 '➜'
    (( _stg_conflicted > 0 )) && _shelltone_git_segment 3 '═'
    (( _stg_untracked > 0 )) && _shelltone_git_segment 6 '✩'
    (( _stg_behind > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_BEHIND_FG" '⇣'
  else
    [[ ${SHELLTONE_SHOW_GIT_ICON:-true} == true ]] && prefix="${SHELLTONE_GIT_ICON:-⎇}  "
    _shelltone_git_segment "$SHELLTONE_GIT_CLEAN_FG" "$prefix$_stg_branch"
    if [[ ${SHELLTONE_GIT_DETAIL:-true} == true ]]; then
      (( _stg_behind > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_BEHIND_FG" "⇣$_stg_behind"
      (( _stg_ahead > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_AHEAD_FG" "⇡$_stg_ahead"
      (( _stg_push_behind > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_PUSH_BEHIND_FG" "⇠$_stg_push_behind"
      (( _stg_push_ahead > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_PUSH_AHEAD_FG" "⇢$_stg_push_ahead"
      (( _stg_stashes > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_CLEAN_FG" "*$_stg_stashes"
      (( _stg_conflicted > 0 )) && _shelltone_git_segment "$SHELLTONE_STATUS_ERROR_FG" "~$_stg_conflicted"
      (( _stg_staged > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_STAGED_FG" "+$_stg_staged"
      (( _stg_changed > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_CHANGED_FG" "!$_stg_changed"
      (( _stg_untracked > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_UNTRACKED_FG" "?$_stg_untracked"
    else
      (( _stg_staged + _stg_changed + _stg_untracked + _stg_conflicted > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_DIRTY_FG" '*'
      (( _stg_behind > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_BEHIND_FG" '⇣'
      (( _stg_ahead > 0 )) && _shelltone_git_segment "$SHELLTONE_GIT_AHEAD_FG" '⇡'
    fi
    [[ -n $_stg_action ]] && _shelltone_git_segment "$SHELLTONE_STATUS_ERROR_FG" "$_stg_action"
  fi
  return 0
}

_shelltone_path() {
  local shown=$PWD max=${SHELLTONE_MAX_DIR_LENGTH:-38} part rest result='' root_name=''
  [[ $PWD != "$HOME" ]] || shown='~'
  [[ $PWD != "$HOME/"* ]] || shown="~/${PWD#"$HOME/"}"
  case ${SHELLTONE_PATH_MODE:-auto} in
    full) REPLY=$shown; return ;;
    basename) REPLY=${shown##*/}; [[ -n $REPLY ]] || REPLY=/; return ;;
  esac
  (( max >= 8 )) || max=8
  (( ${COLUMNS:-80} / 2 >= 8 && max > ${COLUMNS:-80} / 2 )) && max=$((${COLUMNS:-80} / 2))
  # Abbreviate parent components without directory scans; keep the final name.
  rest=$shown
  while [[ $rest == */* ]]; do
    part=${rest%%/*}; rest=${rest#*/}
    if (( ${#shown} > max )) && [[ $part != '~' && -n $part ]]; then
      shown=${shown/"$part/"/"${part:0:1}/"}; part=${part:0:1}
    fi
    result="$result$part/"
  done
  REPLY="$result$rest"
}

_shelltone_literal() {
  # Data must not contain terminal commands or Readline's width delimiters.
  REPLY=${1//[[:cntrl:]]/?}
}

_shelltone_duration() {
  local seconds=$1 days hours minutes
  days=$((seconds / 86400)); hours=$((seconds / 3600 % 24)); minutes=$((seconds / 60 % 60))
  REPLY=''
  (( days > 0 )) && REPLY="${days}d "
  (( hours > 0 )) && REPLY="$REPLY${hours}h "
  (( minutes > 0 )) && REPLY="$REPLY${minutes}m "
  REPLY="$REPLY$((seconds % 60))s"
}

_shelltone_git_clear
