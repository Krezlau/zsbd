import pandas as pd

def process_games():
    try:
        df_games = pd.read_csv('data/games.csv')
        df_lineups = pd.read_csv('data/game_lineups.csv')
        df_events = pd.read_csv('data/game_events.csv')

        lineups_cols = [col for col in df_lineups.columns if col != 'game_id']
        lineups_grouped = df_lineups.groupby('game_id')[lineups_cols].apply(
            lambda x: x.to_dict('records')
        ).reset_index(name='lineups')

        events_cols = [col for col in df_events.columns if col != 'game_id']
        events_grouped = df_events.groupby('game_id')[events_cols].apply(
            lambda x: x.to_dict('records')
        ).reset_index(name='events')

        df_final = pd.merge(df_games, lineups_grouped, on='game_id', how='left')
        df_final = pd.merge(df_final, events_grouped, on='game_id', how='left')

        df_final['lineups'] = df_final['lineups'].apply(
            lambda x: x if isinstance(x, list) else []
        )
        df_final['events'] = df_final['events'].apply(
            lambda x: x if isinstance(x, list) else []
        )

        df_final.to_json('data/games_nested.json', orient='records', lines=True, date_format='iso')
        print("Plik games_nested.json został utworzony.")

    except Exception as e:
        print(f"Błąd: {e}")

if __name__ == "__main__":
    process_games()
