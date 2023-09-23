name: Auto-Reset after PR Merge

on:
  pull_request:
    types:
      - closed
    branches:
      - main
    paths-ignore:
      - .github/workflows/**

jobs:
  reset:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Configure Git
        run: |
          pr_author_username="${{ github.event.pull_request.user.login }}"
          pr_author_email=$(curl -s "https://api.github.com/users/${pr_author_username}" | jq -r '.email')

          git config --global user.name "$pr_author_username"
          git config --global user.email "$pr_author_email"

      - name: Check if PR was merged
        id: check_merged
        run: |
          if [[ "${{ github.event.pull_request.merged }}" != "true" ]]; then
            echo "Pull request was only closed, not merged. Exiting."
            exit 1
          fi

      - name: Reset and push
        run: |
          git fetch origin ${{ github.event.pull_request.base.ref }}
          git fetch origin pull/${{ github.event.pull_request.number }}/head:${{ github.event.pull_request.head.ref }}
          git checkout ${{ github.event.pull_request.head.ref }}
          git reset --hard ${{ github.event.pull_request.base.ref }}
          git push origin ${{ github.event.pull_request.head.ref }} -f
