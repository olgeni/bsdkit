#!/usr/bin/env zsh

#      everyone@:rwxpdDaARWcCos:fdinSFI:allow
#                ||||||||||||||:|||||||
#   (r)read data +|||||||||||||:||||||+ (I)nherited
#   (w)rite data -+||||||||||||:|||||+- (F)ailed access (audit)
#      e(x)ecute --+|||||||||||:||||+-- (S)uccess access (audit)
#       a(p)pend ---+||||||||||:|||+--- (n)o propagate
#       (d)elete ----+|||||||||:||+---- (i)nherit only
# (D)elete child -----+||||||||:|+----- (d)irectory inherit
# read (a)ttrib -------+|||||||:+------ (f)ile inherit
# write (A)ttrib -------+||||||
#   (R)ead xattr --------+|||||
# (W)rite xattr ----------+||||
#     read a(c)l ----------+|||
#    write a(C)l -----------+||
# change (o)wner ------------+|
#           sync -------------+

# Constants for ACL flags:

ACL_TAG_OWNER="owner@"
ACL_TAG_GROUP="group@"
ACL_TAG_EVERYONE="everyone@"

ACL_FLAG_READ_DATA="r"
ACL_FLAG_WRITE_DATA="w"
ACL_FLAG_EXECUTE="x"
ACL_FLAG_APPEND_DATA="p"
ACL_FLAG_DELETE="d"
ACL_FLAG_DELETE_CHILD="D"
ACL_FLAG_READ_ATTRIBUTES="a"
ACL_FLAG_WRITE_ATTRIBUTES="A"
ACL_FLAG_READ_NAMED_ATTRS="R"
ACL_FLAG_WRITE_NAMED_ATTRS="W"
ACL_FLAG_READ_ACL="c"
ACL_FLAG_WRITE_ACL="C"
ACL_FLAG_CHANGE_OWNER="o"
ACL_FLAG_SYNCHRONIZE="s"

ACL_FLAG_FILE_INHERIT="f"
ACL_FLAG_DIRECTORY_INHERIT="d"
ACL_FLAG_INHERIT_ONLY="i"
ACL_FLAG_NO_PROPAGATE="n"
ACL_FLAG_INHERITED="I"

test2() {
    local _acl_string="$1"

    _acl_tag_qualifier=$(echo "${_acl_string}" | cut -d: -f1)

    if [ ${_acl_tag_qualifier} == ${ACL_TAG_OWNER} ] || \
           [ ${_acl_tag_qualifier} == ${ACL_TAG_GROUP} ] || \
           [ ${_acl_tag_qualifier} == ${ACL_TAG_EVERYONE} ]; then
        _acl_tag=$(echo "${_acl_string}" | cut -d: -f1)
        _acl_qualifier=""
        _index=1
    else
        _acl_tag=$(echo "$_acl_string" | cut -d: -f1)
        _acl_qualifier=$(echo "$_acl_string" | cut -d: -f2)
        _index=2
    fi

    _acl_access_permissions=$(echo "${_acl_string}" | cut -d: -f$((_index+1)))
    _acl_inheritance_flags=$(echo "${_acl_string}" | cut -d: -f$((_index+2)))
    _acl_type=$(echo "${_acl_string}" | cut -d: -f$((_index+3)))

    echo "ACL_TAG=$_acl_tag"
    echo "ACL_QUALIFIER=$_acl_qualifier"
    echo "ACL_ACCESS_PERMISSIONS=$_acl_access_permissions"
    echo "ACL_INHERITANCE_FLAGS=$_acl_inheritance_flags"
    echo "ACL_TYPE=$_acl_type"
}

test() {
    _acl_permissions="$1"
    _acl_inheritance_flags="$2"

    # ACL Permissions

    _acl_flag_read_data="off"
    _acl_flag_write_data="off"
    _acl_flag_execute="off"
    _acl_flag_append_data="off"
    _acl_flag_delete="off"
    _acl_flag_delete_child="off"
    _acl_flag_read_attributes="off"
    _acl_flag_write_attributes="off"
    _acl_flag_read_named_attrs="off"
    _acl_flag_write_named_attrs="off"
    _acl_flag_read_acl="off"
    _acl_flag_write_acl="off"
    _acl_flag_change_owner="off"
    _acl_flag_synchronize="off"

    # Inheritance Flags

    _acl_flag_file_inherit="off"
    _acl_flag_directory_inherit="off"
    _acl_flag_inherit_only="off"
    _acl_flag_no_propagate="off"
    _acl_flag_inherited="off"

    # Parse ACL permissions

    for _acl_flag in $(echo $_acl_permissions | sed -e 's/./& /g'); do
        case $_acl_flag in
            r) _acl_flag_read_data="on" ;;
            w) _acl_flag_write_data="on" ;;
            x) _acl_flag_execute="on" ;;
            p) _acl_flag_append_data="on" ;;
            d) _acl_flag_delete="on" ;;
            D) _acl_flag_delete_child="on" ;;
            a) _acl_flag_read_attributes="on" ;;
            A) _acl_flag_write_attributes="on" ;;
            R) _acl_flag_read_named_attrs="on" ;;
            W) _acl_flag_write_named_attrs="on" ;;
            c) _acl_flag_read_acl="on" ;;
            C) _acl_flag_write_acl="on" ;;
            o) _acl_flag_change_owner="on" ;;
            s) _acl_flag_synchronize="on" ;;
        esac
    done

    # Parse Inheritance Flags

    for _acl_flag in $(echo $_acl_inheritance_flags | sed -e 's/./& /g'); do
        case $_acl_flag in
            f) _acl_flag_file_inherit="on" ;;
            d) _acl_flag_directory_inherit="on" ;;
            i) _acl_flag_inherit_only="on" ;;
            n) _acl_flag_no_propagate="on" ;;
            I) _acl_flag_inherited="on" ;;
        esac
    done

    # Edit ACL Permissions and Inheritance Flags

    _acl_permissions_dialog=$(dialog --stdout --checklist "Select the ACL permissions" 26 40 20 \
        "${ACL_FLAG_READ_DATA}" "Read Data" "$_acl_flag_read_data" \
        "${ACL_FLAG_WRITE_DATA}" "Write Data" "$_acl_flag_write_data" \
        "${ACL_FLAG_EXECUTE}" "Execute" "$_acl_flag_execute" \
        "${ACL_FLAG_APPEND_DATA}" "Append Data" "$_acl_flag_append_data" \
        "${ACL_FLAG_DELETE}" "Delete" "$_acl_flag_delete" \
        "${ACL_FLAG_DELETE_CHILD}" "Delete Child" "$_acl_flag_delete_child" \
        "${ACL_FLAG_READ_ATTRIBUTES}" "Read Attributes" "$_acl_flag_read_attributes" \
        "${ACL_FLAG_WRITE_ATTRIBUTES}" "Write Attributes" "$_acl_flag_write_attributes" \
        "${ACL_FLAG_READ_NAMED_ATTRS}" "Read Named Attributes" "$_acl_flag_read_named_attrs" \
        "${ACL_FLAG_WRITE_NAMED_ATTRS}" "Write Named Attributes" "$_acl_flag_write_named_attrs" \
        "${ACL_FLAG_READ_ACL}" "Read ACL" "$_acl_flag_read_acl" \
        "${ACL_FLAG_WRITE_ACL}" "Write ACL" "$_acl_flag_write_acl" \
        "${ACL_FLAG_CHANGE_OWNER}" "Change Owner" "$_acl_flag_change_owner" \
        "${ACL_FLAG_SYNCHRONIZE}" "Synchronize" "$_acl_flag_synchronize" \
        "${ACL_FLAG_FILE_INHERIT}" "File Inherit" "$_acl_flag_file_inherit" \
        "${ACL_FLAG_DIRECTORY_INHERIT}" "Directory Inherit" "$_acl_flag_directory_inherit" \
        "${ACL_FLAG_INHERIT_ONLY}" "Inherit Only" "$_acl_flag_inherit_only" \
        "${ACL_FLAG_NO_PROPAGATE}" "No Propagate" "$_acl_flag_no_propagate" \
        "${ACL_FLAG_INHERITED}" "Inherited" "$_acl_flag_inherited")

    _next_acl_flag_read_data=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_READ_DATA")
    _next_acl_flag_write_data=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_WRITE_DATA")
    _next_acl_flag_execute=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_EXECUTE")
    _next_acl_flag_append_data=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_APPEND_DATA")
    _next_acl_flag_delete=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_DELETE")
    _next_acl_flag_delete_child=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_DELETE_CHILD")
    _next_acl_flag_read_attributes=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_READ_ATTRIBUTES")
    _next_acl_flag_write_attributes=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_WRITE_ATTRIBUTES")
    _next_acl_flag_read_named_attrs=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_READ_NAMED_ATTRS")
    _next_acl_flag_write_named_attrs=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_WRITE_NAMED_ATTRS")
    _next_acl_flag_read_acl=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_READ_ACL")
    _next_acl_flag_write_acl=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_WRITE_ACL")
    _next_acl_flag_change_owner=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_CHANGE_OWNER")
    _next_acl_flag_synchronize=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_SYNCHRONIZE")

    _next_acl_flag_file_inherit=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_FILE_INHERIT")
    _next_acl_flag_directory_inherit=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_DIRECTORY_INHERIT")
    _next_acl_flag_inherit_only=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_INHERIT_ONLY")
    _next_acl_flag_no_propagate=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_NO_PROPAGATE")
    _next_acl_flag_inherited=$(echo "$_acl_permissions_dialog" | grep -o "$ACL_FLAG_INHERITED")

    echo "ACL Flag Read Data" $_acl_flag_read_data
    echo "ACL Flag Write Data" $_acl_flag_write_data
    echo "ACL Flag Execute" $_acl_flag_execute
    echo "ACL Flag Append Data" $_acl_flag_append_data
    echo "ACL Flag Delete" $_acl_flag_delete
    echo "ACL Flag Delete Child" $_acl_flag_delete_child
    echo "ACL Flag Read Attributes" $_acl_flag_read_attributes
    echo "ACL Flag Write Attributes" $_acl_flag_write_attributes
    echo "ACL Flag Read Named Attributes" $_acl_flag_read_named_attrs
    echo "ACL Flag Write Named Attributes" $_acl_flag_write_named_attrs
    echo "ACL Flag Read ACL" $_acl_flag_read_acl
    echo "ACL Flag Write ACL" $_acl_flag_write_acl
    echo "ACL Flag Write Owner" $_acl_flag_change_owner
    echo "ACL Flag Synchronize" $_acl_flag_synchronize
    echo "ACL Flag File Inherit" $_acl_flag_file_inherit
    echo "ACL Flag Directory Inherit" $_acl_flag_directory_inherit
    echo "ACL Flag Inherit Only" $_acl_flag_inherit_only
    echo "ACL Flag No Propagate" $_acl_flag_no_propagate
    echo "ACL Flag Inherited" $_acl_flag_inherited

    echo "Next ACL Flag Read Data" $_next_acl_flag_read_data
    echo "Next ACL Flag Write Data" $_next_acl_flag_write_data
    echo "Next ACL Flag Execute" $_next_acl_flag_execute
    echo "Next ACL Flag Append Data" $_next_acl_flag_append_data
    echo "Next ACL Flag Delete" $_next_acl_flag_delete
    echo "Next ACL Flag Delete Child" $_next_acl_flag_delete_child
    echo "Next ACL Flag Read Attributes" $_next_acl_flag_read_attributes
    echo "Next ACL Flag Write Attributes" $_next_acl_flag_write_attributes
    echo "Next ACL Flag Read Named Attributes" $_next_acl_flag_read_named_attrs
    echo "Next ACL Flag Write Named Attributes" $_next_acl_flag_write_named_attrs
    echo "Next ACL Flag Read ACL" $_next_acl_flag_read_acl
    echo "Next ACL Flag Write ACL" $_next_acl_flag_write_acl
    echo "Next ACL Flag Write Owner" $_next_acl_flag_change_owner
    echo "Next ACL Flag Synchronize" $_next_acl_flag_synchronize
    echo "Next ACL Flag File Inherit" $_next_acl_flag_file_inherit
    echo "Next ACL Flag Directory Inherit" $_next_acl_flag_directory_inherit
    echo "Next ACL Flag Inherit Only" $_next_acl_flag_inherit_only
    echo "Next ACL Flag No Propagate" $_next_acl_flag_no_propagate
    echo "Next ACL Flag Inherited" $_next_acl_flag_inherited

    # create the next acl permissions and inheritance flags

    _next_acl_permissions=""

    if [ "$_next_acl_flag_read_data" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_READ_DATA}"; fi
    if [ "$_next_acl_flag_write_data" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_WRITE_DATA}"; fi
    if [ "$_next_acl_flag_execute" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_EXECUTE}"; fi
    if [ "$_next_acl_flag_append_data" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_APPEND_DATA}"; fi
    if [ "$_next_acl_flag_delete" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_DELETE}"; fi
    if [ "$_next_acl_flag_delete_child" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_DELETE_CHILD}"; fi
    if [ "$_next_acl_flag_read_attributes" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_READ_ATTRIBUTES}"; fi
    if [ "$_next_acl_flag_write_attributes" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_WRITE_ATTRIBUTES}"; fi
    if [ "$_next_acl_flag_read_named_attrs" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_READ_NAMED_ATTRS}"; fi
    if [ "$_next_acl_flag_write_named_attrs" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_WRITE_NAMED_ATTRS}"; fi
    if [ "$_next_acl_flag_read_acl" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_READ_ACL}"; fi
    if [ "$_next_acl_flag_write_acl" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_WRITE_ACL}"; fi
    if [ "$_next_acl_flag_change_owner" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_CHANGE_OWNER}"; fi
    if [ "$_next_acl_flag_synchronize" ]; then _next_acl_permissions="${_next_acl_permissions}${ACL_FLAG_SYNCHRONIZE}"; fi

    _next_acl_inheritance_flags=""

    if [ "$_next_acl_flag_file_inherit" ]; then _next_acl_inheritance_flags="${_next_acl_inheritance_flags}${ACL_FLAG_FILE_INHERIT}"; fi
    if [ "$_next_acl_flag_directory_inherit" ]; then _next_acl_inheritance_flags="${_next_acl_inheritance_flags}${ACL_FLAG_DIRECTORY_INHERIT}"; fi
    if [ "$_next_acl_flag_inherit_only" ]; then _next_acl_inheritance_flags="${_next_acl_inheritance_flags}${ACL_FLAG_INHERIT_ONLY}"; fi
    if [ "$_next_acl_flag_no_propagate" ]; then _next_acl_inheritance_flags="${_next_acl_inheritance_flags}${ACL_FLAG_NO_PROPAGATE}"; fi
    if [ "$_next_acl_flag_inherited" ]; then _next_acl_inheritance_flags="${_next_acl_inheritance_flags}${ACL_FLAG_INHERITED}"; fi

    echo "${_acl_permissions}:${_acl_inheritance_flags} -> ${_next_acl_permissions}:${_next_acl_inheritance_flags}"
}

test2 owner@:rwxp--aARWcCos:-------:allow
test2 user:olgeni:rwxp--aARWcCos:-------:allow
