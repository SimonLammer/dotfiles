path=${1:-$(pwd)}

path=$(
  echo $path | sed -E "\
    s<^$HOME<~<;\
    s<^(~?\/([^\/]{1,5}\/|[^\/]{5}))[^\/].*(.{50})$<\1…\3<\
  "
)

echo $path