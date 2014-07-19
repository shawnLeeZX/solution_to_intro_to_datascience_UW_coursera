
-- (a) select: Write a query that is equivalent to the following relational
-- algebra expression.

-- σ10398_txt_earn(frequency)

-- What to turn in: Run your query against your local database and determine
-- the number of records returned. On the assignment page, upload a text file,
-- select.txt, which includes a single line with the number of records.

select * 
from frequency
where docid = '10398_txt_earn';

-- (b) select project: Write a SQL statement that is equivalent to the
-- following relational algebra expression.

-- πterm(σdocid=10398_txt_earn and count=1(frequency))

-- What to turn in: Run your query against your local database and determine
-- the number of records returned as described above. upload a text file
-- select_project.txt which states the number of records.

select term
from frequency
where docid = '10398_txt_earn' and count = 1;

-- (c) union: Write a SQL statement that is equivalent to the following
-- relational algebra expression. (Hint: you can use the UNION keyword in SQL)

-- πterm(σdocid=10398_txt_earn and count=1(frequency)) U
-- πterm(σdocid=925_txt_trade and count=1(frequency))

-- What to turn in: Run your query against your local database and determine
-- the number of records returned as described above. In your browser, upload a
-- text file union.txt with a single line containing the number of records.

select term
from frequency
where docid = '10398_txt_earn' and count = 1
union 
select term
from frequency
where docid = '925_txt_trade' and count = 1;

-- (d) count: Write a SQL statement to count the number of documents containing
-- the word "parliament"

-- What to turn in: Run your query against your local database and determine
-- the count returned as described above. On the assignment page, upload a text
-- file count.txt with a single line containing the number of records.

select count(*)
from frequency
where term = 'parliament';

-- (e) big documents Write a SQL statement to find all documents that have more
-- than 300 total terms, including duplicate terms. (Hint: You can use the
    -- HAVING clause, or you can use a nested query. Another hint: Remember
    -- that the count column contains the term frequencies, and you want to
    -- consider duplicates.) (docid, term_count)

-- What to turn in: Run your query against your local database and determine
-- the number of records returned as described above. On the assignment page,
-- upload a text file big_documents.txt with a single line containing the
-- number of records.

select docid, sum(count) as term_count
from frequency
group by docid
having term_cou;

-- (f) two words: Write a SQL statement to count the number of unique documents
-- that contain both the word 'transactions' and the word 'world'.

-- What to turn in: Run your query against your local database and determine
-- the number of records returned as described above. On the assignment page,
-- upload a text file two_words.txt with a single line containing the number of
-- records.

select count(*)
from frequency as fa, frequency as fb
where fa.docid = fb.docid 
  and fa.term = 'transactions'
  and fb.term = 'world';

-- (g) multiply: Express A X B as a SQL query, referring to the class lecture for
-- hints.

select a.row_num, b.col_num, sum(a.value * b.value)
from a, b
where a.col_num = b.row_num
group by a.row_num, b.col_num;

(h) similarity matrix: Write a query to compute the similarity matrix DDT.
(Hint: The transpose is trivial -- just join on columns to columns instead
    of columns to rows.) The query could take some time to run if you
compute the entire result. But notice that you don't need to compute the
similarity of both (doc1, doc2) and (doc2, doc1) -- they are the same, since
similarity is symmetric. If you wish, you can avoid this wasted work by
adding a condition of the form a.docid < b.docid to your query. (But the
    query still won't return immediately if you try to compute every result
    -- don't expect otherwise.)

-- This line is the statement to compute all similarities

select fa.docid, fb.docid, sum(fa.count * fb.count)
from frequency as fa, frequency fb
where
  fa.docid > fb.docid and
  fa.term = fb.term;

-- However, for saving time, I directly compute the similarity asked for submission.

select fa.docid, fb.docid, sum(fa.count * fb.count)
from frequency as fa, frequency fb
where
  fa.docid = '10080_txt_crude' and
  fb.docid = '17035_txt_earn' and
  fa.term = fb.term;

-- (i) keyword search: Find the best matching document to the keyword query
-- "washington taxes treasury". You can add this set of keywords to the
-- document corpus with a union of scalar queries:

create view query as
select * from frequency
union
select 'q' as docid, 'washington' as term, 1 as count 
union
select 'q' as docid, 'taxes' as term, 1 as count
union 
select 'q' as docid, 'treasury' as term, 1 as count;

select qb.docid, sum(qa.count * qb.count) as similarity
from query qa, query qb
where
  qa.docid = 'q' and
  qb.docid != 'q' and
  qa.term = qb.term
group by qb.docid
order by similarity;
