#!/bin/sh

# Get the GitHub Token and Giphy API Key
GITHUB_TOKEN=$1
GIPHY_API_KEY=$2

#  Get the Pull Request Number
pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
echo PR Number - $pull_request_number

# Use the Giphy API to Fetch a Random "Thank You" GIF
giphy_response=$(curl -s "https://api.giphy.com/v1/gifs/random?api_key=$GIPHY_API_KEY&tag=thank%20you&rating=g")
echo Giphy Response - $giphy_response

# Extract the GIF URL from the Giphy Response
gif_url=$(echo "$giphy_response" | jq --raw-output .data.images.downsized.url)
echo GIPHY_URL - $gif_url

# Create a Comment with the GIF on the Pull Request
comment_response=$(curl -s -X POST -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  -d "{\"body\": \"![GIF]($gif_url) \n Thank you for this contribution \n [GIF]($gif_url) \"}" \
  https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$pull_request_number/comments)
echo Comment Response - $comment_response

# Extract and Print the Comment URL
comment_url=$(echo "$comment_response" | jq --raw-output .html_url)
echo Comment URL - $comment_url

