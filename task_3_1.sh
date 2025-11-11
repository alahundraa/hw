#!/usr/bin/env bash
# Экстрасенс (простая версия с комментариями)
# Игра: компьютер загадывает число 0–9, вы пытаетесь угадать.
# 'q' — выход. После каждого хода показывается статистика и последние 10 чисел.

# Безопасные настройки bash:
# -e — выход при ошибке
# -u — ошибка при обращении к несуществующей переменной
# -o pipefail — передаёт код ошибки из пайпов
set -euo pipefail

# Цвета для вывода (зелёный = угадал, красный = промах)
GREEN=$'\e[32m'
RED=$'\e[31m'
RESET=$'\e[0m'

# Переменные для статистики
steps=0   # всего попыток
hits=0    # количество угаданных
nums=()   # массив загаданных чисел
marks=()  # массив: 1 — угадал, 0 — нет

# Функция для вывода статистики
print_stats() {
  local hit_pct=0 miss_pct=0
  if (( steps > 0 )); then
    hit_pct=$(( hits * 100 / steps ))
    miss_pct=$(( (steps - hits) * 100 / steps ))
  fi
  echo "Hit: ${hit_pct}%  Miss: ${miss_pct}%"

  # Печатаем последние 10 чисел (угаданные — зелёные, нет — красные)
  echo -n "Numbers: "
  local total=${#nums[@]}
  local start=0
  (( total > 10 )) && start=$(( total - 10 ))
  for (( i=start; i<total; i++ )); do
    if (( marks[i] == 1 )); then
      echo -ne "${GREEN}${nums[i]}${RESET}"
    else
      echo -ne "${RED}${nums[i]}${RESET}"
    fi
    (( i < total-1 )) && echo -n " "
  done
  echo
}

# Главный игровой цикл
while true; do
  step=$(( steps + 1 ))          # номер хода
  secret=$(( RANDOM % 10 ))      # генерируем случайное число 0..9

  echo "Step: ${step}"

  # Цикл ввода — ждём корректное число или 'q'
  while true; do
    read -r -p "Please enter number from 0 to 9 (q - quit): " input || {
      echo; echo "Bye!"; exit 0;
    }

    # Проверка на выход
    [[ "$input" == "q" ]] && { echo "Bye!"; exit 0; }

    # Проверка: введена ли ровно одна цифра 0–9
    if [[ "$input" =~ ^[0-9]$ ]]; then
      guess=$input
      break
    else
      echo "Invalid input. Enter a SINGLE digit 0..9 or 'q'."
    fi
  done

  # Проверяем результат
  steps=$(( steps + 1 ))
  if (( guess == secret )); then
    echo "Hit! My number: ${secret}"
    hits=$(( hits + 1 ))
    nums+=( "$secret" )
    marks+=( 1 )     # запоминаем, что угадал
  else
    echo "Miss! My number: ${secret}"
    nums+=( "$secret" )
    marks+=( 0 )     # запоминаем, что не угадал
  fi

  # Печатаем статистику
  print_stats
done

