-- ════════════════════════════════════════════════════════════
--  WageWise – Supabase PostgreSQL Schema
--  Run this entire file in: Supabase Dashboard → SQL Editor
-- ════════════════════════════════════════════════════════════

-- Enable UUID extension (already enabled on Supabase by default)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─────────────────────────────────────────────────────────────
-- 1. USER_PROFILES
--    Extends Supabase auth.users with app-specific fields.
--    auth.users is managed automatically by Supabase Auth.
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.user_profiles (
  user_id       UUID        PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name     TEXT        NOT NULL,
  language_pref TEXT        NOT NULL DEFAULT 'en'
                            CHECK (language_pref IN ('en', 'bm', 'zh', 'ta')),
  salary_goal   NUMERIC(10,2),
  education     TEXT,
  field_of_study TEXT,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE public.user_profiles IS
  'App-level user data extending Supabase auth.users.';

-- ─────────────────────────────────────────────────────────────
-- 2. SALARY_PREDICTIONS  (UC 100 → UC 101 → UC 102)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.salary_predictions (
  prediction_id    UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id          UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  job_title        TEXT        NOT NULL,
  industry         TEXT        NOT NULL,
  education_level  TEXT        NOT NULL,
  years_experience INTEGER     NOT NULL CHECK (years_experience >= 0),
  location         TEXT        NOT NULL,
  predicted_p25    NUMERIC(10,2),
  predicted_p50    NUMERIC(10,2),
  predicted_p75    NUMERIC(10,2),
  confidence_label TEXT        CHECK (confidence_label IN ('low', 'medium', 'high')),
  offer_amount     NUMERIC(10,2),
  offer_status     TEXT        CHECK (offer_status IN ('below_market', 'at_market', 'above_market')),
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_salary_predictions_user
  ON public.salary_predictions(user_id, created_at DESC);

COMMENT ON TABLE public.salary_predictions IS
  'Stores each salary prediction result per user (UC 100-102).';

-- ─────────────────────────────────────────────────────────────
-- 3. CHAT_SESSIONS  (UC 200, UC 300)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_sessions (
  session_id   UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  module_type  TEXT        NOT NULL
               CHECK (module_type IN ('labour_rights', 'negotiation_coach', 'contract_review')),
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_sessions_user
  ON public.chat_sessions(user_id, created_at DESC);

COMMENT ON TABLE public.chat_sessions IS
  'Groups chat messages by session and module type.';

-- ─────────────────────────────────────────────────────────────
-- 4. CHAT_MESSAGES
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.chat_messages (
  message_id  UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  session_id  UUID        NOT NULL REFERENCES public.chat_sessions(session_id) ON DELETE CASCADE,
  role        TEXT        NOT NULL CHECK (role IN ('user', 'bot')),
  content     TEXT        NOT NULL,
  sources     JSONB,                    -- RAG citation references
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_chat_messages_session
  ON public.chat_messages(session_id, created_at ASC);

COMMENT ON TABLE public.chat_messages IS
  'Individual messages within a chat session.';

-- ─────────────────────────────────────────────────────────────
-- 5. COL_EVALUATIONS  (UC 400 → UC 401 → UC 402)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.col_evaluations (
  evaluation_id      UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id            UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  gross_salary       NUMERIC(10,2) NOT NULL,
  epf_deduction      NUMERIC(10,2) NOT NULL,
  socso_deduction    NUMERIC(10,2) NOT NULL,
  tax_deduction      NUMERIC(10,2) NOT NULL DEFAULT 0,
  net_salary         NUMERIC(10,2) NOT NULL,
  city               TEXT        NOT NULL,
  rent               NUMERIC(10,2) NOT NULL DEFAULT 0,
  food               NUMERIC(10,2) NOT NULL DEFAULT 0,
  transport          NUMERIC(10,2) NOT NULL DEFAULT 0,
  utilities          NUMERIC(10,2) NOT NULL DEFAULT 0,
  healthcare         NUMERIC(10,2) NOT NULL DEFAULT 0,
  total_expenses     NUMERIC(10,2) NOT NULL,
  disposable_income  NUMERIC(10,2) NOT NULL,
  meets_living_wage  BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_col_evaluations_user
  ON public.col_evaluations(user_id, created_at DESC);

COMMENT ON TABLE public.col_evaluations IS
  'Stores cost-of-living breakdown per city per user (UC 400-402).';

-- ─────────────────────────────────────────────────────────────
-- 6. NEGOTIATION_SESSIONS  (UC 200 → UC 201)
-- ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.negotiation_sessions (
  session_id   UUID        PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id      UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  scenario     TEXT        NOT NULL CHECK (scenario IN ('lowball_offer', 'ask_for_raise')),
  score        INTEGER     CHECK (score BETWEEN 0 AND 100),
  feedback     TEXT,
  turns        INTEGER     NOT NULL DEFAULT 0,
  completed    BOOLEAN     NOT NULL DEFAULT FALSE,
  created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_negotiation_sessions_user
  ON public.negotiation_sessions(user_id, created_at DESC);

COMMENT ON TABLE public.negotiation_sessions IS
  'Negotiation coach practice sessions with scores (UC 200-201).';

-- ─────────────────────────────────────────────────────────────
-- 7. Row Level Security (RLS)
--    Users may only read/write their own rows.
-- ─────────────────────────────────────────────────────────────

ALTER TABLE public.user_profiles       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.salary_predictions  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_sessions       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.chat_messages       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.col_evaluations     ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.negotiation_sessions ENABLE ROW LEVEL SECURITY;

-- user_profiles
CREATE POLICY "Users manage own profile"
  ON public.user_profiles FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- salary_predictions
CREATE POLICY "Users manage own predictions"
  ON public.salary_predictions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- chat_sessions
CREATE POLICY "Users manage own chat sessions"
  ON public.chat_sessions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- chat_messages (access via session ownership)
CREATE POLICY "Users read own chat messages"
  ON public.chat_messages FOR SELECT
  USING (
    session_id IN (
      SELECT session_id FROM public.chat_sessions
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users insert own chat messages"
  ON public.chat_messages FOR INSERT
  WITH CHECK (
    session_id IN (
      SELECT session_id FROM public.chat_sessions
      WHERE user_id = auth.uid()
    )
  );

-- col_evaluations
CREATE POLICY "Users manage own COL evaluations"
  ON public.col_evaluations FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- negotiation_sessions
CREATE POLICY "Users manage own negotiation sessions"
  ON public.negotiation_sessions FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- ─────────────────────────────────────────────────────────────
-- 8. Auto-update updated_at trigger for user_profiles
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_user_profiles_updated_at
  BEFORE UPDATE ON public.user_profiles
  FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ─────────────────────────────────────────────────────────────
-- 9. Auto-create user_profile on sign-up
-- ─────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  INSERT INTO public.user_profiles (user_id, full_name)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email)
  );
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─────────────────────────────────────────────────────────────
-- Done! Verify with:
--   SELECT tablename FROM pg_tables WHERE schemaname = 'public';
-- ─────────────────────────────────────────────────────────────
