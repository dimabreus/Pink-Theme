# vim:ft=zsh ts=2 sw=2 sts=2
#
# Pink Theme - Based on agnoster's Theme
# A Powerline-inspired theme for ZSH in pink tones
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

CURRENT_BG='NONE'

# Characters
SEGMENT_SEPARATOR="\ue0b0"
PLUSMINUS="\u00b1"
BRANCH="\ue0a0"
DETACHED="\u27a6"
CROSS="\u2718"
LIGHTNING="\u26a1"
GEAR="\u2699"

ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f52742'

ZSH_HIGHLIGHT_STYLES[command]='fg=#f788ba'
ZSH_HIGHLIGHT_STYLES[alias]='fg=#e888f7'
ZSH_HIGHLIGHT_STYLES[function]='fg=#aa78fa'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#f788ba'

# Пути и строки - цвет 218 (светло-розовый)
ZSH_HIGHLIGHT_STYLES[path]='fg=218,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=218'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=218'

# Опции (флаги, например -l) - цвет 205 (средний розовый)
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=205'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=205'

# ==============================================
# НАСТРОЙКА ЦВЕТОВ (Pastel Pink)
# ==============================================

# Мы используем формат RGB: 38;2;R;G;B
# #f788ba (Rose)  -> 247;136;186
# #e888f7 (Lilac) -> 232;136;247

# di = директории (Rose Bold)
# ex = исполняемые файлы (Lilac Bold)
# ln = ссылки (Lilac)
# ow = папки с правами записи для всех (подсвечиваем Rose)
# mi/or = битые ссылки (Красный, чтобы было видно ошибку)

export LS_COLORS="di=1;38;2;247;136;186:ex=1;38;2;232;136;247:ln=38;2;232;136;247:so=38;2;247;136;186:pi=38;2;247;136;186:bd=38;2;247;136;186:cd=38;2;247;136;186:su=1;38;2;232;136;247:sg=1;38;2;232;136;247:tw=38;2;247;136;186:ow=38;2;247;136;186:st=38;2;247;136;186:mi=1;31:or=1;31"

# Применяем эти цвета к меню выбора (TAB)
# ma (выбранный элемент):
# Фон = #f788ba (Rose) -> 48;2;247;136;186
# Текст = Черный (для контраста на светлом фоне) -> 38;5;0
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}" "ma=48;2;247;136;186;38;5;0"

# 3. Настройка заголовков групп (например, "-- Commands --")
zstyle ':completion:*:*:*:*:descriptions' format '%F{213}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{213}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format ' %F{197} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{197} -- No matches found --%f'

# 4. Группировка результатов (сначала файлы, потом папки и т.д.)
zstyle ':completion:*' group-name ''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    print -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    print -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && print -n $3
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    print -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    print -n "%{%k%}"
  fi
  print -n "%{%f%}"
  CURRENT_BG=''
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  if [[ -n "$SSH_CLIENT" ]]; then
    # SSH session - более яркий розовый
    prompt_segment 213 white "%{$fg_bold[white]%(!.%{%F{white}%}.)%}$USER@%m%{$fg_no_bold[white]%}"
  else
    # Локальная сессия - светло-розовый фон с темным текстом
    prompt_segment 218 161 "%{$fg_bold[161]%(!.%{%F{161]%}.)%}@$USER%{$fg_no_bold[161]%}"
  fi
}

# Battery Level
prompt_battery() {
  HEART='♥ '

  if [[ $(uname) == "Darwin" ]] ; then

    function battery_is_charging() {
      [ $(ioreg -rc AppleSmartBattery | grep -c '^.*"ExternalConnected"\ =\ No') -eq 1 ]
    }

    function battery_pct() {
      local smart_battery_status="$(ioreg -rc "AppleSmartBattery")"
      typeset -F maxcapacity=$(echo $smart_battery_status | grep '^.*"MaxCapacity"\ =\ ' | sed -e 's/^.*"MaxCapacity"\ =\ //')
      typeset -F currentcapacity=$(echo $smart_battery_status | grep '^.*"CurrentCapacity"\ =\ ' | sed -e 's/^.*CurrentCapacity"\ =\ //')
      integer i=$(((currentcapacity/maxcapacity) * 100))
      echo $i
    }

    function battery_pct_remaining() {
      if battery_is_charging ; then
        battery_pct
      else
        echo "External Power"
      fi
    }

    function battery_time_remaining() {
      local smart_battery_status="$(ioreg -rc "AppleSmartBattery")"
      if [[ $(echo $smart_battery_status | grep -c '^.*"ExternalConnected"\ =\ No') -eq 1 ]] ; then
        timeremaining=$(echo $smart_battery_status | grep '^.*"AvgTimeToEmpty"\ =\ ' | sed -e 's/^.*"AvgTimeToEmpty"\ =\ //')
        if [ $timeremaining -gt 720 ] ; then
          echo "::"
        else
          echo "~$((timeremaining / 60)):$((timeremaining % 60))"
        fi
      fi
    }

    b=$(battery_pct_remaining)
    if [[ $(ioreg -rc AppleSmartBattery | grep -c '^.*"ExternalConnected"\ =\ No') -eq 1 ]] ; then
      if [ $b -gt 50 ] ; then
        prompt_segment 211 white
      elif [ $b -gt 20 ] ; then
        prompt_segment 217 white
      else
        prompt_segment 197 white
      fi
      echo -n "%{$fg_bold[white]%}$HEART$(battery_pct_remaining)%%%{$fg_no_bold[white]%}"
    fi
  fi

  if [[ $(uname) == "Linux" && -d /sys/module/battery ]] ; then

    function battery_is_charging() {
      ! [[ $(acpi 2&>/dev/null | grep -c '^Battery.*Discharging') -gt 0 ]]
    }

    function battery_pct() {
      if (( $+commands[acpi] )) ; then
        echo "$(acpi | cut -f2 -d ',' | tr -cd '[:digit:]')"
      fi
    }

    function battery_pct_remaining() {
      if [ ! $(battery_is_charging) ] ; then
        battery_pct
      else
        echo "External Power"
      fi
    }

    function battery_time_remaining() {
      if [[ $(acpi 2&>/dev/null | grep -c '^Battery.*Discharging') -gt 0 ]] ; then
        echo $(acpi | cut -f3 -d ',')
      fi
    }

    b=$(battery_pct_remaining)
    if [[ $(acpi 2&>/dev/null | grep -c '^Battery.*Discharging') -gt 0 ]] ; then
      if [ $b -gt 40 ] ; then
        prompt_segment 211 white
      elif [ $b -gt 20 ] ; then
        prompt_segment 217 white
      else
        prompt_segment 197 white
      fi
      echo -n "%{$fg_bold[white]%}$HEART$(battery_pct_remaining)%%%{$fg_no_bold[white]%}"
    fi

  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
#«»±˖˗‑‐‒ ━ ✚‐↔←↑↓→↭⇎⇔⋆━◂▸◄►◆☀★☗☊✔✖❮❯⚑⚙
  local PL_BRANCH_CHAR
  () {
    local LC_ALL="" LC_CTYPE="en_US.UTF-8"
    PL_BRANCH_CHAR="$BRANCH"
  }
  local ref dirty mode repo_path clean has_upstream
  local modified untracked added deleted tagged stashed
  local ready_commit git_status bgclr fgclr
  local commits_diff commits_ahead commits_behind has_diverged to_push to_pull

  repo_path=$(git rev-parse --git-dir 2>/dev/null)

  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    dirty=$(parse_git_dirty)
    git_status=$(git status --porcelain 2> /dev/null)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git rev-parse --short HEAD 2> /dev/null)"
    if [[ -n $dirty ]]; then
      clean=''
      bgclr='217'  # Светло-розовый для dirty
      fgclr='89'   # Темно-розовый текст
    else
      clean=' ✔'
      bgclr='211'  # Розовый для clean
      fgclr='white'
    fi

    local upstream=$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)
    if [[ -n "${upstream}" && "${upstream}" != "@{upstream}" ]]; then has_upstream=true; fi

    local current_commit_hash=$(git rev-parse HEAD 2> /dev/null)

    local number_of_untracked_files=$(\grep -c "^??" <<< "${git_status}")
    if [[ $number_of_untracked_files -gt 0 ]]; then untracked=" $number_of_untracked_files☀"; fi

    local number_added=$(\grep -c "^A" <<< "${git_status}")
    if [[ $number_added -gt 0 ]]; then added=" $number_added✚"; fi

    local number_modified=$(\grep -c "^.M" <<< "${git_status}")
    if [[ $number_modified -gt 0 ]]; then
      modified=" $number_modified●"
      bgclr='197'  # Яркий розовый для модификаций
      fgclr='white'
    fi

    local number_added_modified=$(\grep -c "^M" <<< "${git_status}")
    local number_added_renamed=$(\grep -c "^R" <<< "${git_status}")
    if [[ $number_modified -gt 0 && $number_added_modified -gt 0 ]]; then
      modified="$modified$((number_added_modified+number_added_renamed))±"
    elif [[ $number_added_modified -gt 0 ]]; then
      modified=" ●$((number_added_modified+number_added_renamed))±"
    fi

    local number_deleted=$(\grep -c "^.D" <<< "${git_status}")
    if [[ $number_deleted -gt 0 ]]; then
      deleted=" $number_deleted‒"
      bgclr='161'  # Темно-розовый для удалений
      fgclr='white'
    fi

    local number_added_deleted=$(\grep -c "^D" <<< "${git_status}")
    if [[ $number_deleted -gt 0 && $number_added_deleted -gt 0 ]]; then
      deleted="$deleted$number_added_deleted±"
    elif [[ $number_added_deleted -gt 0 ]]; then
      deleted=" ‒$number_added_deleted±"
    fi

    local tag_at_current_commit=$(git describe --exact-match --tags $current_commit_hash 2> /dev/null)
    if [[ -n $tag_at_current_commit ]]; then tagged=" ☗$tag_at_current_commit "; fi

    local number_of_stashes="$(git stash list -n1 2> /dev/null | wc -l)"
    if [[ $number_of_stashes -gt 0 ]]; then
      stashed=" ${number_of_stashes##*(  )}⚙"
      bgclr='205'  # Средний розовый для stash
      fgclr='white'
    fi

    if [[ $number_added -gt 0 || $number_added_modified -gt 0 || $number_added_deleted -gt 0 ]]; then ready_commit=' ⚑'; fi

    local upstream_prompt=''
    if [[ $has_upstream == true ]]; then
      commits_diff="$(git log --pretty=oneline --topo-order --left-right ${current_commit_hash}...${upstream} 2> /dev/null)"
      commits_ahead=$(\grep -c "^<" <<< "$commits_diff")
      commits_behind=$(\grep -c "^>" <<< "$commits_diff")
      upstream_prompt="$(git rev-parse --symbolic-full-name --abbrev-ref @{upstream} 2> /dev/null)"
      upstream_prompt=$(sed -e 's/\/.*$/ ☊ /g' <<< "$upstream_prompt")
    fi

    has_diverged=false
    if [[ $commits_ahead -gt 0 && $commits_behind -gt 0 ]]; then has_diverged=true; fi
    if [[ $has_diverged == false && $commits_ahead -gt 0 ]]; then
      if [[ $bgclr == '197' || $bgclr == '205' || $bgclr == '161' ]] then
        to_push=" $fg_bold[white]↑$commits_ahead$fg_bold[$fgclr]"
      else
        to_push=" $fg_bold[89]↑$commits_ahead$fg_bold[$fgclr]"
      fi
    fi
    if [[ $has_diverged == false && $commits_behind -gt 0 ]]; then to_pull=" $fg_bold[213]↓$commits_behind$fg_bold[$fgclr]"; fi

    if [[ -e "${repo_path}/BISECT_LOG" ]]; then
      mode=" <B>"
    elif [[ -e "${repo_path}/MERGE_HEAD" ]]; then
      mode=" >M<"
    elif [[ -e "${repo_path}/rebase" || -e "${repo_path}/rebase-apply" || -e "${repo_path}/rebase-merge" || -e "${repo_path}/../.dotest" ]]; then
      mode=" >R>"
    fi

    prompt_segment $bgclr $fgclr

    print -n "%{$fg_bold[$fgclr]%}${ref/refs\/heads\//$PL_BRANCH_CHAR $upstream_prompt}${mode}$to_push$to_pull$clean$tagged$stashed$untracked$modified$deleted$added$ready_commit%{$fg_no_bold[$fgclr]%}"
  fi
}

prompt_hg() {
  local rev status
  if $(hg id >/dev/null 2>&1); then
    if $(hg prompt >/dev/null 2>&1); then
      if [[ $(hg prompt "{status|unknown}") = "?" ]]; then
        # if files are not added
        prompt_segment 197 white
        st='±'
      elif [[ -n $(hg prompt "{status|modified}") ]]; then
        # if any modification
        prompt_segment 217 89
        st='±'
      else
        # if working copy is clean
        prompt_segment 211 white
      fi
      print -n $(hg prompt "☿ {rev}@{branch}") $st
    else
      st=""
      rev=$(hg id -n 2>/dev/null | sed 's/[^-0-9]//g')
      branch=$(hg id -b 2>/dev/null)
      if `hg st | grep -q "^\?"`; then
        prompt_segment 197 white
        st='±'
      elif `hg st | grep -q "^[MA]"`; then
        prompt_segment 217 89
        st='±'
      else
        prompt_segment 211 white
      fi
      print -n "☿ $rev@$branch" $st
    fi
  fi
}

#Dir: current working directory
prompt_dir() {
  prompt_segment 213 white "%{$fg_bold[white]%}%~%{$fg_no_bold[white]%}"
}

# Virtualenv: current working virtualenv
prompt_virtualenv() {
  local virtualenv_path="$VIRTUAL_ENV"
  if [[ -n $virtualenv_path && -n $VIRTUAL_ENV_DISABLE_PROMPT ]]; then
    prompt_segment 219 89 "(`basename $virtualenv_path`)"
  fi
}

prompt_time() {
  prompt_segment 205 white "%{$fg_bold[white]%}%D{%a %e %b - %H:%M}%{$fg_no_bold[white]%}"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{197}%}$CROSS"
  [[ $UID -eq 0 ]] && symbols+="%{%F{213}%}$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{219}%}$GEAR"

  [[ -n "$symbols" ]] && prompt_segment 89 default "$symbols"
}

## Main prompt
build_prompt() {
  RETVAL=$?
  print -n "\n"
  prompt_status
  #prompt_battery
  prompt_time
  prompt_virtualenv
  prompt_dir
  prompt_git
  prompt_hg
  prompt_end
  CURRENT_BG='NONE'
  print -n "\n"
  prompt_context
  prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '