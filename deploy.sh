#!/bin/bash

doHelmOperation() {
  if [[ "$1" == "delete" ]]; then
    helm $1 "$name"
  else
    helm install "$name" "$package" -f "helm/$values"
  fi
}

doOperation() {
  if [[ "$2" == "all" ]]; then
    for r in */*; do
      if [[ "$r" == *"helm/"* ]]; then
        continue
      fi
      echo "$1 $r..."
      kubectl $1 -f $r;
    done
    while read -r name package values;  do
      doHelmOperation $1 $name $package $values
    done <helm-packages.txt
  else
    for r in $2/*; do
      echo "$1 $r..."
      kubectl $1 -f $r;
    done
    while read -r name package values;  do
      if [[ "$2" == "$name" ]]; then
        doHelmOperation $1 $name $package $values
      fi
    done <helm-packages.txt
  fi

}

doDelete() {
  echo "SERVICE $1"
  if [ -z "$1" ]
    then
      echo """
      it is necessary to inform the services to delete
      ex: './deploy.sh delete all' will delete all services
          './deploy.sh delete kafka' will delete only kafka
      """
      exit 1
  else
    SERVICE=$1
    echo "SERVICE $SERVICE"
    doOperation delete $SERVICE
  fi
}

doApply() {
  if [ -z "$1" ]
    then
      echo """
      it is necessary to inform the services to apply
      ex: './deploy.sh apply all' will apply all services
          './deploy.sh apply kafka' will apply only kafka
      """
      exit 1
    else
      SERVICE=$1
      doOperation apply $SERVICE
  fi
}

if [ -z "$1" ]
  then
    echo """
    it is necessary to inform the operation
    ex: './deploy.sh apply all' will apply all services
        './deploy.sh delete all' will delete all services
        './deploy.sh delete kafka' will delete only kafka
    """
else
  OPERATION=$1
  echo "OPERATION $OPERATION"
  case $OPERATION in
    delete) doDelete $2 ;;
    apply)  doApply $2 ;;
  esac
fi

