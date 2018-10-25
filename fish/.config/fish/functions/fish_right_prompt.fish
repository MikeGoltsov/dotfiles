function kubectl_status
  [ -z "$KUBECTL_PROMPT_ICON" ]; and set -l KUBECTL_PROMPT_ICON "⎈"
  [ -z "$KUBECTL_PROMPT_SEPARATOR" ]; and set -l KUBECTL_PROMPT_SEPARATOR "/"
  set -l config $KUBECONFIG
  [ -z "$config" ]; and set -l config "$HOME/.kube/config"
  if [ ! -f $config ]
    echo (set_color red)$KUBECTL_PROMPT_ICON" "(set_color white)"no config"
    return
  end

  set -l ctx (kubectl config current-context 2>/dev/null)
  if [ $status -ne 0 ]
    echo (set_color red)$KUBECTL_PROMPT_ICON" "(set_color white)"no context"
    return
  end

  set -l color_k8s white
  set -l color_k8s_icon cyan
  switch $ctx
  	case "o-stg"
			set color_k8s yellow
			set color_k8s_icon bryellow
  	case o-prod  o-prod-new
			set color_k8s red
			set color_k8s_icon brred
  	case "o-cicd-infra"
			set color_k8s green
			set color_k8s_icon brgreen
  end

  set -l ns (kubectl config view -o "jsonpath={.contexts[?(@.name==\"$ctx\")].context.namespace}")
  [ -z $ns ]; and set -l ns 'default'

  echo (set_color $color_k8s_icon)$KUBECTL_PROMPT_ICON" "(set_color $color_k8s)"($ctx$KUBECTL_PROMPT_SEPARATOR$ns)"
end

function fish_right_prompt
	echo (kubectl_status)
	echo " "

	set_color $fish_color_autosuggestion ^/dev/null; or set_color 555
	date "+%H:%M:%S "

	echo "$CMD_DURATION ms"
	set_color normal
end
