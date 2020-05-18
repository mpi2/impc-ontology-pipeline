#!/usr/bin/env python
# coding: utf-8

# In[1]:


import pandas as pd

prefix = "http://mousephenotype.org/ontology#"

curie_map = dict()
curie_map['impc']=prefix
curie_map['MP']='http://purl.obolibrary.org/obo/MP_'
curie_map['HP']='http://purl.obolibrary.org/obo/HP_'
curie_map['oio']='http://www.geneontology.org/formats/oboInOwl#'
curie_map['rdfs']='http://www.w3.org/2000/01/rdf-schema#'


# In[2]:


df_mp_l = pd.read_csv('tables/mp_lexical.csv')
df_hp_l = pd.read_csv('tables/hp_lexical.csv')
df_mp_p = pd.read_csv('tables/mp_parentage.csv')
df_mp_hp = pd.read_csv('tables/mp_hp_matches.csv')
df_mp_l['property']


# In[3]:


df_mp_l.head()


# In[4]:


df_hp_l.head()


# In[5]:


print(len(df_mp_p))
df_mp_p.columns = ['x','y']
df_mp_p=df_mp_p[df_mp_p['x']!=df_mp_p['y']]
print(len(df_mp_p))
df_mp_p.head()


# In[6]:


df_mp_hp=df_mp_hp[['x','y']]
df_mp_hp.head()


# In[7]:





# In[8]:


def match_pre(df_hp_l,df_mp_hp,prop,prop_name):
    dfh = df_hp_l[df_hp_l['property']==prop]
    dfh = dfh.merge(right=df_mp_hp,left_on='phenotype', right_on='x', how='inner')
    df = dfh[['y','property','value']]
    df.columns = ['phenotype','property','value']
    df['property']=prefix+prop_name
    return df


# In[9]:


dfhl = match_pre(df_hp_l,df_mp_hp,"http://www.w3.org/2000/01/rdf-schema#label","hpLabel")
dfhl.head()


# In[10]:


dfhs = match_pre(df_hp_l,df_mp_hp,"http://www.geneontology.org/formats/oboInOwl#hasExactSynonym","hpExactSynonym")
dfhs.head()


# In[11]:


df_child1_s = match_pre(df_mp_l,df_mp_p,'http://www.geneontology.org/formats/oboInOwl#hasExactSynonym',"childOneSynonym")
df_child1_s.head()


# In[12]:


df_child1_l = match_pre(df_mp_l,df_mp_p,"http://www.w3.org/2000/01/rdf-schema#label","childOneLabel")
df_child1_l.head()


# In[14]:


df_mp_c2 = df_mp_p.copy()
df_mp_c2.columns = ['sub','phenotype']
df_mp_c2 = df_mp_c2.merge(right=df_mp_p,left_on='sub', right_on='y', how='inner')
df_mp_c2=df_mp_c2[['phenotype','x']].drop_duplicates()
df_mp_c2.columns = ['y','x']
df_mp_c2.head()


# In[15]:


df_child2_s = match_pre(df_mp_l,df_mp_c2,'http://www.geneontology.org/formats/oboInOwl#hasExactSynonym',"childTwoSynonym")
df_child2_s.head()


# In[16]:


df_child2_l = match_pre(df_mp_l,df_mp_c2,'http://www.w3.org/2000/01/rdf-schema#label',"childTwoLabel")
df_child2_l.head()


# In[17]:


#df_mp_c3 = df_mp_c2.copy()
#df_mp_c3.columns = ['sub','phenotype']
#df_mp_c3 = df_mp_c3.merge(right=df_mp_p,left_on='sub', right_on='y', how='inner')
#df_mp_c3=df_mp_c3[['phenotype','x']].drop_duplicates()
#df_mp_c3.columns = ['y','x']
#df_mp_c3.head()


# In[38]:


df=pd.concat([df_mp_l,df_child1_l,df_child1_s,df_child2_s,df_child2_l,dfhs,dfhl])
df.head()


# In[39]:


def curie_replace(x, curie_map):
    y = x
    for prefix in curie_map:
        y = y.replace(curie_map[prefix],prefix+":")
    return y

df.drop_duplicates(inplace = True)
df['phenotype'] = df.apply(lambda row: curie_replace(row['phenotype'], curie_map), axis=1)
df['property'] = df.apply(lambda row: curie_replace(row['property'], curie_map), axis=1)

df.head()


# In[40]:


df['property'].value_counts()


# In[41]:


df.reset_index(inplace=True,drop=True)
df.to_csv("tables/impc_search_index.csv",index=False)


# In[42]:


#df[df['phenotype']=='MP:0005266'].to_csv("impc_example_")

