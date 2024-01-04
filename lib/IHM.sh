main_menu() {
    debug "main_menu $*"
    init_if_absent_repo
    MENU=(
        "Visualiser_état_courant_du_stock"
        "Modifier_une_entrée"
        "Ajouter_une_entrée"
        "Rechercher_une_entrée"
        "EXIT"
    )
    select choice in ${MENU[@]}; do
        case $REPLY in
        1)
            synchronize
            display_inventory_sum_up
            break
            ;;
        2)
            synchronize
            update_entry
            break
            ;;
        3)
            synchronize
            create_and_add_entry_to_database_file_and_then_push_it
            break
            ;;
        4)
            synchronize
            read_entry
            break
            ;;
        5)
            exit_ok
            ;;
        *)
            print "valeur inconnue : $REPLY"
            ;;
        esac
    done
    main_menu
}

display_inventory() {
    debug "display_inventory $*"
}

synchronize() {
    debug "synchronize $*"
    move_to_local_folder
    git fetch
    git checkout origin/${default_main_branch} 2>/dev/nul
}

create_and_add_entry_to_database_file_and_then_push_it() {
    debug "create_and_add_entry_to_database_file_and_then_push_it $*"
    
    # saisie dirigée
    display_all_existing_labels
    print "Saisissez un libellé unique de la pièce : "
    read -p "--> " libelle_unique
    libelle_unique=${libelle_unique^^}
    libelle_unique=${libelle_unique// /_}
    print "Saisissez une unité : "
    select unite in ${UNITS[*]}; do
        break
    done
    print "Saisissez un emplacement : "
    select emplacement in ${EMPLACEMENTS[*]}; do
        break
    done
    print "Saisissez une quantité : "
    read -p "--> " quantite
    print "Saisissez une affectation (ou vide): "
    read -p "--> " affectation
    print_separator
    print "Confirmez la saisie : ${ORANGE_STYLE}${libelle_unique} ${quantite} ${unite} "
    print "Optionnel : emplacement=${emplacement}"
    if [[ ! -z ${affectation} ]]; then
        print "Optionnel : affecté à ${affectation}"
    fi

    # confirmation utilisateur
    yes_or_repeat "create_and_add_entry_to_database_file_and_then_push_it"
    # manip git pour le transactionnel
    reference_date=$(date +"%Y_%m_%d_%H_%M")
    add_entry_to_database_file "${libelle_unique};${unite};${emplacement};${quantite};${affectation};${reference_date}"
    temp_branch_name="move_${reference_date}"
    commit_merge_and_delete ${temp_branch_name}
}

read_entry() {
    debug "read_entry $*"
}

update_entry() {
    debug "update_entry $*"
}
