import pandas as pd

def process_players_full():
    try:
        df_players = pd.read_csv('data/players.csv')
        df_valuations = pd.read_csv('data/player_valuations.csv')
        df_appearances = pd.read_csv('data/appearances.csv')

        cols_to_drop_val = ['current_club_id', 'player_club_domestic_competition_id']
        df_valuations.drop(columns=cols_to_drop_val, errors='ignore', inplace=True)
        
        val_cols = [col for col in df_valuations.columns if col != 'player_id']
        valuations_grouped = df_valuations.groupby('player_id')[val_cols].apply(
            lambda x: x.to_dict('records')
        ).reset_index(name='market_value_history')

        cols_to_drop_app = ['player_current_club_id', 'player_name']
        df_appearances.drop(columns=cols_to_drop_app, errors='ignore', inplace=True)

        app_cols = [col for col in df_appearances.columns if col != 'player_id']
        appearances_grouped = df_appearances.groupby('player_id')[app_cols].apply(
            lambda x: x.to_dict('records')
        ).reset_index(name='appearances')

        df_final = pd.merge(df_players, valuations_grouped, on='player_id', how='left')
        df_final = pd.merge(df_final, appearances_grouped, on='player_id', how='left')

        for col in ['market_value_history', 'appearances']:
            df_final[col] = df_final[col].apply(
                lambda x: x if isinstance(x, list) else []
            )

        df_final.to_json('data/players_nested.json', orient='records', lines=True, date_format='iso')
        print("Plik players_full_nested.json został utworzony.")

    except Exception as e:
        print(f"Błąd: {e}")

if __name__ == "__main__":
    process_players_full()
