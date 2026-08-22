/*
# Create start_conversation RPC Function

## Overview
Creates a SECURITY DEFINER function that starts or retrieves a conversation
between the authenticated user and another user for a specific product.

## Security
- SECURITY DEFINER so it can insert into both conversations and conversation_participants
  in a single call (the conversation_participants INSERT policy checks auth.uid() = user_uid,
  but the function runs as the owner to create the conversation row first).
- Uses auth.uid() to identify the caller.

## Notes
- If a conversation already exists between these two users for this product, returns it.
- Otherwise creates a new conversation and adds both participants.
*/

CREATE OR REPLACE FUNCTION start_conversation(other_uid text, product_id uuid DEFAULT NULL)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  conv_id uuid;
  existing_conv_id uuid;
BEGIN
  SELECT c.id INTO existing_conv_id
  FROM conversations c
  WHERE c.product_id IS NOT DISTINCT FROM product_id
  AND EXISTS (SELECT 1 FROM conversation_participants cp WHERE cp.conversation_id = c.id AND cp.user_uid = auth.uid()::text)
  AND EXISTS (SELECT 1 FROM conversation_participants cp WHERE cp.conversation_id = c.id AND cp.user_uid = other_uid)
  LIMIT 1;

  IF existing_conv_id IS NOT NULL THEN
    RETURN existing_conv_id;
  END IF;

  INSERT INTO conversations (product_id) VALUES (product_id) RETURNING id INTO conv_id;

  INSERT INTO conversation_participants (conversation_id, user_uid) VALUES (conv_id, auth.uid()::text);
  INSERT INTO conversation_participants (conversation_id, user_uid) VALUES (conv_id, other_uid);

  RETURN conv_id;
END;
$$;
