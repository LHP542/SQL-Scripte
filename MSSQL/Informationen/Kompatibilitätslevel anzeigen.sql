select name, compatibility_level, recovery_model_desc, page_verify_option_desc from sys.databases
where compatibility_level < 160
order by name