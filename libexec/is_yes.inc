is_yes() {
    # Return 0 if the argument is a positive answer, 1 if it is a negative
    case $1 in
        [Yy][Ee][Ss])
            return 0
            ;;
        [Nn][Oo])
            return 1
            ;;
        [Tt][Rr][Uu][Ee])
            return 0
            ;;
        [Ff][Aa][Ll][Ss][Ee])
            return 1
            ;;
        [Oo][Nn])
            return 0
            ;;
        [Oo][Ff][Ff])
            return 1
            ;;
        *)
            if [[ $1 == <-> ]]; then
                [ $1 -ne 0 ]
            else
                return 2
            fi
            ;;
    esac
}