import os
import subprocess


def find_git_repos_with_locate():
    """Find Git repositories using the locate command."""
    try:
        result = subprocess.run(
            ["locate", ".git"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        if result.returncode != 0:
            print(f"Error finding repositories: {result.stderr}")
            return []

        # Filter directories ending with `.git`
        git_repos = [line.rstrip('.git') for line in result.stdout.splitlines() if line.endswith('.git')]
        return git_repos

    except FileNotFoundError:
        print("The 'locate' command is not available. Please ensure it is installed.")
        return []

def update_git_remotes(repo_path):
    """Update remote URLs in a Git repository."""
    try:
        result = subprocess.run(
            ['git', '-C', repo_path, 'remote', '-v'],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        if result.returncode != 0:
            print(f"Failed to list remotes in {repo_path}: {result.stderr}")
            return

        lines = result.stdout.splitlines()
        for line in lines:
            parts = line.split()
            if len(parts) < 2:
                continue
            remote_name, remote_url = parts[0], parts[1]
            if 'iaik.tugraz.at' in remote_url:
                new_url = remote_url.replace('iaik.tugraz.at', 'isec.tugraz.at')
                subprocess.run(
                    ['git', '-C', repo_path, 'remote', 'set-url', remote_name, new_url],
                    check=True
                )
                print(f"Updated remote '{remote_name}' in {repo_path}:\n  Old URL: {remote_url}\n  New URL: {new_url}")

    except subprocess.CalledProcessError as e:
        print(f"Error updating remotes in {repo_path}: {e}")

def main():
    print("Finding Git repositories using 'locate'...")
    git_repos = find_git_repos_with_locate()
    if not git_repos:
        print("No Git repositories found.")
        return

    print(f"Found {len(git_repos)} Git repository(ies). Updating remotes...")
    for repo in git_repos:
        update_git_remotes(repo)

    print("Done.")

if __name__ == "__main__":
    main()

