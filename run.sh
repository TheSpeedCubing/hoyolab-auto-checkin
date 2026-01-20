#!/bin/bash

PLAYERS_YAML="players.yaml"
YQ=/usr/local/bin/yq

cd "$(dirname "$0")"

players_count=$($YQ e '.players | length' "$PLAYERS_YAML")

games=("Genshin Impact" "Honkai: Star Rail" "Honkai Impact 3" "Tears of Themis" "Zenless Zone Zero")
urls=(
  "https://sg-hk4e-api.hoyolab.com/event/sol/sign?act_id=e202102251931481"
  "https://sg-public-api.hoyolab.com/event/luna/os/sign?act_id=e202303301540311"
  "https://sg-public-api.hoyolab.com/event/mani/sign?act_id=e202110291205111"
  "https://sg-public-api.hoyolab.com/event/luna/os/sign?act_id=e202202281857121"
  "https://sg-public-api.hoyolab.com/event/luna/zzz/os/sign?act_id=e202406031448091"
)

language="en"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
CYAN="\033[36m"
RESET="\033[0m"

for ((i=0; i<players_count; i++)); do
  name=$($YQ e ".players[$i].name" "$PLAYERS_YAML")
  token=$($YQ e ".players[$i].token" "$PLAYERS_YAML")

  echo -e "${CYAN}====== Signing in for ${name} ======${RESET}"

  for j in "${!games[@]}"; do
    case ${games[$j]} in
      "Genshin Impact") key="genshin_impact" ;;
      "Honkai: Star Rail") key="honkai_star_rail" ;;
      "Honkai Impact 3") key="honkai_impact_3" ;;
      "Tears of Themis") key="tears_of_themis" ;;
      "Zenless Zone Zero") key="zenless_zone_zero" ;;
      *) echo -e "${RED}Unknown game: ${games[$j]}${RESET}" ; continue ;;
    esac

    play_flag=$($YQ e ".players[$i].$key" "$PLAYERS_YAML")
    if [ "$play_flag" = "true" ]; then
      echo -e "${YELLOW}-> Signing in for ${games[$j]}...${RESET}"
      
      headers=(-H "Content-Type: application/json" -H "Cookie: $token" -H "User-Agent: Mozilla/5.0")

      # zzz fix
      if [ "${games[$j]}" = "Zenless Zone Zero" ]; then
        headers+=(-H "X-RPC-Signgame: zzz")
      fi

      response=$(curl -s -X POST "${urls[$j]}&lang=${language}" "${headers[@]}")

      if echo "$response" | jq . >/dev/null 2>&1; then
        echo -e "${GREEN}Response:${RESET}"
        echo "$response" | jq .
      else
        echo -e "${RED}Error: response is not valid JSON or request failed.${RESET}"
        echo "$response"
      fi
    fi
  done

  echo -e "\n"
done
