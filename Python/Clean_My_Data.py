import pandas as pd

#load data set
df = pd.read_csv('data.csv')

#inspect the structure of the data
print(df.info())
print(df.describe())
print(df.head())

#check for missing values
missing_values= df.isnull().sum()
print("Missing values:\n", missing_values)

#indentify duplicate rows
duplicates = df.duplicated()
print("Duplicate rows:", duplicates.sum())

#identify outliers using IQR method
Q1 = df['column_name'].quantile(0.25)
Q3 = df['column_name'].quantile(0.75)
IQR = Q3 - Q1
outliers = ((df < (Q1 - 1.5 * IQR)) | (df > (Q3 + 1.5 * IQR))).sum()
print("Outliers detected using IQR method:\n", outliers)

#drop rows with missing values
df_cleaned = df.dropna()

#drop columns with missing values
df_cleaned = df_cleaned.dropna(axis=1)

#impute missing values with mean
df['column_name'] = df['column_name'].fillna(df['column_name'].mean())

#impute missing values with a constant value
df['column_name'] = df['column_name'].fillna(0)

#Machine learning Imputation (e.g., using KNN)
from sklearn.impute import KNNImputer
imputer = KNNImputer(n_neighbors=5)
df[['column_name']] = imputer.fit_transform(df[['column_name']])

#drop duplicate rows
df_cleaned = df.drop_duplicates()

#drop duplicate rows based on specific columns
df_cleaned = df.drop_duplicates(subset=['column1', 'column2'])

#cap outliers at a certain threshold
df['column_name'] = df['column_name'].clip(lower=lower_bound, upper=upper_bound)

#log transformation to reduce the impact of outliers
df['column_name']= np.log1p(df['column_name'])

#convert date column to standard format
df['date_column'] = pd.to_datetime(df['date_column'], format='%Y-%m-%d', errors='coerce')

#standardize text data
df['text_column'] = df['text_column'].str.lower().str.strip()

from great_expectations.dataset import PandasDataset

df_ge = PandasDataset(df)
df_ge.expect_column_values_to_not_be_null('email')
df_ge.expect_column_values_to_exist('customer_id')
df_ge.expect_column_values_to_be_unique('customer_id')

df['year'] = df['timestamp'].dt.year
df['month'] = df['timestamp'].dt.month
df['day'] = df['timestamp'].dt.day
df['hour'] = df['timestamp'].dt.hour
df['minute'] = df['timestamp'].dt.minute
df['second'] = df['timestamp'].dt.second
df['day_of_week'] = df['timestamp'].dt.dayofweek
df['is_weekend'] = df['day_of_week'].apply(lambda x: 1 if x >= 5 else 0)

#Example: Prioritize source a over source b
df['final_name'] = df['name_source_a'].combine_first(df['name_source_b'])

missing_references = df[~df['foreign_key'].isin(df['parent_table']['primary_key'])]
print("missing foreign key references: ", len(missing_references))


#pick from the above and put in a function:

def clean_data(df):
    # Remove rows with missing values
    df_cleaned = df.dropna()
    
    # Remove duplicate rows
    df_cleaned = df_cleaned.drop_duplicates()
    
    # Convert date columns to datetime format
    for col in df_cleaned.select_dtypes(include=['object']).columns:
        try:
            df_cleaned[col] = pd.to_datetime(df_cleaned[col], errors='coerce')
        except Exception as e:
            print(f"Error converting {col}: {e}")
    
    return df_cleaned

def test_missing_value_handling():
    input_data = pd.DataFrame({"A": [1, None, 3]})
    cleaned_data = clean_data(input_data)
    assert cleaned_data['A'].isnull().sum() == 0