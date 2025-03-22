#!/bin/sh
set -e

# Get the GitHub Token and Giphy API Key
GITHUB_TOKEN=$1
GIPHY_API_KEY=$2

# Check if tokens are available
if [ -z "$GITHUB_TOKEN" ]; then
  echo "Error: GITHUB_TOKEN is empty"
  exit 1
else
  echo "GITHUB_TOKEN is set (length: ${#GITHUB_TOKEN})"
fi

if [ -z "$GIPHY_API_KEY" ]; then
  echo "Error: GIPHY_API_KEY is empty"
  exit 1
else
  echo "GIPHY_API_KEY is set (length: ${#GIPHY_API_KEY})"
fi

#  Get the Pull Request Number
pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
echo PR Number - $pull_request_number

if [ -z "$pull_request_number" ] || [ "$pull_request_number" = "null" ]; then
  echo "Error: Could not extract pull request number from event payload"
  echo "Event payload content:"
  cat "$GITHUB_EVENT_PATH"
  exit 1
fi

# Use the Giphy API to Fetch a Random "Thank You" GIF
giphy_response=$(curl -s "https://api.giphy.com/v1/gifs/random?api_key=$GIPHY_API_KEY&tag=thank%20you&rating=g")
echo Giphy Response - $giphy_response

# Extract the GIF URL from the Giphy Response
gif_url=$(echo "$giphy_response" | jq --raw-output .data.images.downsized.url)
echo GIPHY_URL - $gif_url

if [ -z "$gif_url" ] || [ "$gif_url" = "null" ]; then
  echo "Warning: Could not extract GIF URL, using fallback"
  gif_url="https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExcDd1bXFxcWsxdHd4ZHF4bnJxOXJ1NXF1cXNxaWF4aHJ1aXhxdWlpbyZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/l0MYt5jPR6QX5pnqM/giphy.gif"
fi

# Create a Comment with the GIF on the Pull Request
echo "Posting comment to PR #$pull_request_number in $GITHUB_REPOSITORY"
comment_response=$(curl -v -X POST \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -H "Content-Type: application/json" \
  -d "{\"body\": \"![GIF]($gif_url) \n\nThank you for this contribution! \n\n\"}" \
  "https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$pull_request_number/comments")

echo "Comment Response - $comment_response"

# Extract and Print the Comment URL
comment_url=$(echo "$comment_response" | jq --raw-output .html_url)
echo "Comment URL - $comment_url"

if [ -z "$comment_url" ] || [ "$comment_url" = "null" ]; then
  echo "Error: Failed to post comment"
  exit 1
else
  echo "Successfully posted comment: $comment_url"
fi

