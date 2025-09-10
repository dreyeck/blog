let remote = $"($env.SSH_USER)@($env.SSH_HOST)"
let localPath = "./dist/"

print $"ℹ️ Uploading ($localPath) to ($env.REMOTE_DEPLOY_DIR) on remote host ($remote)"

(rsync --recursive --update --delete --human-readable --progress $"--port=($env.SSH_PORT)"
  $localPath
  $"($remote):($env.REMOTE_DEPLOY_DIR)"
)

print "✅ Done!"
