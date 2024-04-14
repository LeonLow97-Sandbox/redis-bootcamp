import redis

## variables
file = 'allkeys_values.txt'
url = 'redis://localhost:6379'
query = '*' ## take all keys, can define any pattern e.g., '*name', 'key:??'

print("Reading keys...", end='')

client = redis.StrictRedis.from_url(url, decode_responses=True)
keys = client.keys(query)

print(f"{len(keys)} keys found.")

def chunks(lst, n):
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

partitions = list(chunks(keys, 10000))

with open(file, 'w', newline='\n', encoding='utf-8') as f:
    for i in range(0, len(partitions)):
        progress = ((i+1)/len(partitions)) * 100
        print(f"\rProcessing values... {progress:.2f}%", end='')

        keys = partitions[i]
        values = client.mget(keys)

        for i in zip(keys, values):
            f.write(i[0])
            f.write('\n')
            f.write(i[1])
            f.write('\n')

print('\nProcessing Done...')
