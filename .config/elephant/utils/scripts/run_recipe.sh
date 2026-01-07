#!/bin/bash
RECIPE_PATH="$1"

# Dependency checks
command -v yq &> /dev/null || { echo "Error: yq missing"; exit 1; }
command -v gum &> /dev/null || { echo "Error: gum missing"; exit 1; }

cmd_args=("run" "--no-session" "--recipe" "$RECIPE_PATH")
echo "---"
echo "Configuring: $RECIPE_PATH"

# read the YAML configuration into a stream, redirect input from the process substitution at the bottom of the loop.
while IFS=$'\t' read -r key req desc; do

    label="Enter value for: $key"

    if [[ "$req" == "optional" ]]; then
        label="$label (Optional - Press Enter to skip)"
    fi

    value=""
    while true; do
        # '< /dev/tty' to force gum to read from keyboard regardless of the loop's input stream.
        value=$(gum input --header "$label" --placeholder "$desc" < /dev/tty)

        if [[ "$req" == "required" && -z "$value" ]]; then
            # Show a temporary error using gum (optional, but nice)
            gum style --foreground "#FF0000" "Value is required!" < /dev/tty
            continue
        elif [[ "$req" == "optional" && -z "$value" ]]; then
            break
        else
            break
        fi
    done

    if [[ -n "$value" ]]; then
        cmd_args+=("--params" "$key=$value")
    fi

done < <(yq -r '.parameters[] | [.key, .requirement, .description] | @tsv' "$RECIPE_PATH")

echo "Executing recipe: goose ${cmd_args[*]}"
echo ">>>"

exec goose "${cmd_args[@]}"

# read -p "[Press Enter to close]"
