#!/bin/bash

# Shows status of selected wine dlls (like for DX11).
# Inspired by https://www.winehq.org/winapi_stats.
# The script works best in terminals with true color support,
# but it should work with less colors as well.

function no_clr()
{
   printf '\x1b[0m'
}

# color setting functions usage
# <func> $red $green $blue [$flag]
#
# useful flags:
# 0 - nothing
# 1 - bold
# 3 - italic
# 4 - underline
# 5 - blink
function fg_rgb()
{
   if (($# < 4)); then
       printf "\x1b[38;2;${1};${2};${3}m"
   else
       printf "\x1b[${4};38;2;${1};${2};${3}m"
   fi
}

function bg_rgb()
{
   if (($# < 4)); then
       printf "\x1b[48;2;${1};${2};${3}m"
   else
       printf "\x1b[${4};48;2;${1};${2};${3}m"
   fi
}

function light_shift()
{
   local v1=$1
   local v2=$2
   local shift=$3 # between [0.0, 1.0]
   local res=$(calc "$v1 * (1 - $shift) + $v2 * $shift")
   precision=0 round $res
}

function rgb_gradient()
{
   local r1=$1
   local g1=$2
   local b1=$3
   local r2=$4
   local g2=$5
   local b2=$6
   local shift=$7 # between [0.0, 1.0]

   printf "$(light_shift $r1 $r2 $shift) $(light_shift $g1 $g2 $shift) $(light_shift $b1 $b2 $shift)"
}

# expects any math expression supported by bc
function calc()
{
   precision=${precision:-19}
   local res=$(LC_ALL=C printf "%.${precision}f\n" $(echo "$@" | bc -l 2>/dev/null))
   # dropping trailing zeros. Using %.20g produces bug for 0.9 for example, so using %.19g
   LC_ALL=C printf "%.19g\n" "$res"
}

function round()
{
   precision=${precision:-19}
   local res=$(LC_ALL=C printf "%.${precision}f\n" "$1")
   # dropping trailing zeros. Using %.20g produces bug for 0.9 for example, so using %.19g
   LC_ALL=C printf "%.19g\n" "$res"
}

function get_stats()
{
   local source="$1"
   local -a statuses=( $(curl --silent "${source}" | cut -d ' ' -f 2) )

   local stubs=0
   local calls=0
   local total=0

   for status in ${statuses[@]}; do
      if [ "$status" == "stub" ]; then
         ((stubs++))
      elif [ "$status" == "stdcall" ]; then
         ((calls++))
      fi
   done

   dll=${source##*/}
   dll=${dll%%\.spec}

   ((total = stubs + calls))
   readiness=$(calc "$calls / $total")
   readiness_percent=$(precision=1 calc "$readiness * 100")

   # 0% rgb
   r_0=255
   g_0=30
   b_0=30
   # 100% rgb
   r_100=80
   g_100=255
   b_100=80

   clr="$(bg_rgb $(rgb_gradient $r_0 $g_0 $b_0 $r_100 $g_100 $b_100 $readiness))$(fg_rgb 0 0 0)"
   echo "${dll}: ${clr}${readiness_percent}%$(no_clr)"
}

############################################

sources=(
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3dcompiler_43/d3dcompiler_43.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3dcompiler_46/d3dcompiler_46.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3dcompiler_47/d3dcompiler_47.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3d10/d3d10.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3d10_1/d3d10_1.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3dx10_39/d3dx10_39.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3dx10_43/d3dx10_43.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3d11/d3d11.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3dx11_42/d3dx11_42.spec"
 "https://source.winehq.org/git/wine.git/blob_plain/HEAD:/dlls/d3dx11_43/d3dx11_43.spec"
)

############################################

for source in ${sources[@]}; do
   get_stats "${source}"
done