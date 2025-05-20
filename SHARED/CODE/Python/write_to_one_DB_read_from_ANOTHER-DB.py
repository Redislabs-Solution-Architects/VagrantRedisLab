import redis
import random

sredis_h = "redis-10001.re-cluster1.ps-redislabs.org"
sredis_p = 10001
sredis_pwd = ""

dredis_h = "redis-10002.re-cluster1.ps-redislabs.org"
dredis_p = 10002
dredis_pwd = ""

lst_key = "test"
# first element id
val_first_element = 1
# last element id
val_last_element = 100


def redis_run():

    # push to O-Redis
    try:
        o_r = redis.Redis(host=sredis_h, port=sredis_p, password=sredis_pwd, decode_responses=True)   
    except Exception as err:
        print(err)
    # if key does not exist
    if not o_r.exists(lst_key):
        for x in range(val_first_element,val_last_element+1):
            o_r.rpush(lst_key, 'id:' + str(x) + ',rvalue:' + str(random.getrandbits(128)))

    # pull from E-Redis
    try:
        e_r = redis.Redis(host=dredis_h, port=dredis_p, password=dredis_pwd, decode_responses=True)   
    except Exception as err:
        print(err)
    # get all elements from list
    l_elements = e_r.lrange( lst_key, 0, -1 )
    # len to print
    l_elements_count = len(l_elements)
    # for reversing idx
    l_elements_idx_count = l_elements_count - 1
    print('LRANGE len: ' + str(l_elements_count))
    
    for i in range(len(l_elements)):
        print (str(i+1) + ' - L->R: ' + str(l_elements[i]) + ' | ' + str(l_elements[l_elements_idx_count-i]) + ' :L<-R')

    # delete list from O-Redis
    o_r.delete(lst_key)

if __name__ == '__main__':
    redis_run()