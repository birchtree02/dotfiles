# Define the NOTES_FOLDER variable
export NOTES_FOLDER=/Users/edwardbirchall/OneDrive/Documents/notes

# Define the journal function
journal() {
  local folder="$NOTES_FOLDER/journal"
  local template="$folder/template.md"
  local destination

  if [ -n "$1" ]; then
    folder="$NOTES_FOLDER/$1/journal"
    template="$folder/template.md"
  fi

  destination="$folder/$(date +'%Y-%m-%d').md"

  # Create the destination directory if it doesn't exist
  if [ ! -d "$folder" ]; then
    mkdir -p "$folder"
    echo "Created directory $folder"
  fi

  # Check if the template exists, if not create a blank file
  if [ ! -f "$template" ]; then
    echo "Template not found at $template. Creating a blank file."
    touch "$template"
  fi

  # Check if the destination file already exists
  if [ ! -f "$destination" ]; then
    # Copy the template to the destination
    cp "$template" "$destination"

    # Replace <date> in the destination file with today's date
    replace_date_in_template "$destination"

    echo "Journal entry created at $destination"
  else
    echo "Journal entry already exists at $destination"
  fi

  # Open the note in neovim from the NOTES_FOLDER directory
  (cd "$NOTES_FOLDER" && nvim "$destination")
}

# Define the replace_date_in_template function
replace_date_in_template() {
  local file="$1"
  local current_date
  current_date=$(date +"%A %dth %B")

  # Replace <date> with the current date
  sed -i '' "s/<date>/$current_date/" "$file"
}


# Define the note function
note() {
  local folder="$NOTES_FOLDER/$1"
  local name="$2"
  local template="$folder/template.md"
  local destination="$folder/${name}-$(date +'%Y-%m-%d').md"

  # Create the destination directory if it doesn't exist
  if [ ! -d "$folder" ]; then
    mkdir -p "$folder"
    echo "Created directory $folder"
  fi

  # Check if the template exists, if not create a blank file
  if [ ! -f "$template" ]; then
    echo "Template not found at $template. Creating a blank file."
    touch "$template"
  fi

  # Check if the destination file already exists
  if [ ! -f "$destination" ]; then
    # Copy the template to the destination
    cp "$template" "$destination"

    # Replace <date> in the destination file with today's date
    replace_date_in_template "$destination"

    echo "Note created at $destination"
  else
    echo "Note already exists at $destination"
  fi

  # Open the note in neovim from the NOTES_FOLDER directory
  (cd "$NOTES_FOLDER" && nvim "$destination")
}

# Define the replace_date_in_template function
replace_date_in_template() {
  local file="$1"
  local current_date
  current_date=$(date +"%A %dth %B")

  # Replace <date> with the current date
  sed -i '' "s/<date>/$current_date/" "$file"
}
