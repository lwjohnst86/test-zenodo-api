# Build website on release

# Run this script on release

# Where ZENODO_TOKEN is stored.
. ./env

API_URL="https://sandbox.zenodo.org/api/deposit/depositions"
REPO_URL="https://github.com/steno-aarhus/none"

own_deposits=$(curl \
  --header "Authorization: Bearer $ZENODO_TOKEN" \
  $API_URL
)

echo $own_deposits
jq '.[].links.html' <<< $own_deposits

get_deposit_id_for_repo() {
  cat $1 | \
    jq --arg repo "${2}" \
    '.[] | select(.metadata.related_identifiers[]?.identifier | contains($repo)).id' $1
}
deposit_id=$(get_deposit_id_for_repo $own_deposits $REPO_URL)

curl -i -H "Authorization: Bearer ACCESS_TOKEN" https://zenodo.org/api/deposit/depositions/1234/files


# Update an already published deposition

# Create a new version
curl -i -X POST -H "Authorization: Bearer ACCESS_TOKEN" \
  https://zenodo.org/api/deposit/depositions/1234/actions/newversion

# Update the metadata
curl -i -H "Content-Type: application/json" -H "Authorization: Bearer ACCESS_TOKEN" -X PUT
     --data '{"metadata": {"title": "My first upload", "upload_type": "poster", "description": "This is my first upload", "creators": [{"name": "Doe, John", "affiliation": "Zenodo"}]}}' https://zenodo.org/api/deposit/depositions/1234

# Delete the original file
curl -i -H "Authorization: Bearer ACCESS_TOKEN" -X DELETE https://zenodo.org/api/deposit/depositions/1234/files/21fedcba-9876-5432-1fed-cba987654321

# Upload a new file
curl -i \
  --header "Authorization: Bearer $ZENODO_TOKEN" \
  $zen_files_url \
  -F name=dmp.pdf \
  -F file=@dmp.pdf


# Update existing release:
# - Get metadata from repository (fail if not found)
# - Get deposition ID (fail if more than one)
# - Convert deposit to editable
# - Update metadata
# - Get list of file IDs
# - Delete each file
# - Create new version
