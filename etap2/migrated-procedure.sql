CREATE OR REPLACE PROCEDURE "transfers"."sp_ExecutePlayerTransfer"(
    p_player_id INT,
    p_from_club_id INT,
    p_to_club_id INT,
    p_fee DECIMAL(18, 2),
    p_transfer_date DATE
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_club_id INT;
BEGIN
    IF NOT EXISTS (SELECT 1 FROM "transfers"."players" WHERE id = p_player_id) THEN
        RAISE EXCEPTION 'Error: Player with the specified ID does not exist.';
    END IF;

    IF p_from_club_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "transfers"."clubs" WHERE id = p_from_club_id) THEN
        RAISE EXCEPTION 'Error: The "From" club (from_club_id) does not exist.';
    END IF;

    IF p_to_club_id IS NOT NULL AND NOT EXISTS (SELECT 1 FROM "transfers"."clubs" WHERE id = p_to_club_id) THEN
        RAISE EXCEPTION 'Error: The "To" club (to_club_id) does not exist.';
    END IF;

    IF p_from_club_id = p_to_club_id THEN
        RAISE EXCEPTION 'Error: Cannot execute a transfer to the same club.';
    END IF;

    SELECT current_club_id INTO v_current_club_id
    FROM "transfers"."players"
    WHERE id = p_player_id;

    IF COALESCE(v_current_club_id, 0) != COALESCE(p_from_club_id, 0) THEN
        RAISE EXCEPTION 'Error: Player is not currently assigned to the specified "From" club (from_club_id).';
    END IF;

    INSERT INTO "transfers"."transfers"
        (player_id, from_club_id, to_club_id, transfer_date, fee)
    VALUES
        (p_player_id, p_from_club_id, p_to_club_id, p_transfer_date, p_fee);

    UPDATE "transfers"."players"
    SET current_club_id = p_to_club_id
    WHERE id = p_player_id;

    RAISE NOTICE 'Transfer executed successfully.';
END;
$$;