import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
import boto3
from datetime import datetime, timedelta

## @params: [TempDir, JOB_NAME]
args = getResolvedOptions(sys.argv, ['TempDir','JOB_NAME'])

glueContext = GlueContext(SparkContext.getOrCreate())
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)
## @type: DataSource
## @args: [database = "s3toredshift_sub", table_name = "0803_05", transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
glue_client = boto3.client('glue', region_name='ap-northeast-1')
last_hour_date_time = datetime.now() - timedelta(hours = 1)
day_partition_value = last_hour_date_time.strftime("%Y-%m-%d")
hour_partition_value = last_hour_date_time.strftime("%-H")
day_partition_value = day_partition_value
hour_partition_value = hour_partition_value
yearname = day_partition_value[0:4]
monthname = day_partition_value[5:7]
dayname = day_partition_value[8:10]
if len(hour_partition_value) < 2:
    hour_partition_value = '0' + hour_partition_value
s3_location = 's3://processed-data-todatalake/george_demo/'+str(yearname)+'/'+str(monthname)+'/'+str(dayname)+'/'+hour_partition_value+'/'
print(s3_location)

## @type: DataSource
## @args: [database = "s3toredshift_sub", table_name = dynamic, transformation_ctx = "datasource0"]
## @return: datasource0
## @inputs: []
datasource0 = glueContext.create_dynamic_frame.from_options("s3", connection_options={"paths": [s3_location]}, format="json", transformation_ctx = "df1")
rownumber = datasource0.count()
print(rownumber)
applymapping1 = ApplyMapping.apply(frame = datasource0, mappings = [("kubernetes.labels.projectAccount", "string", "projectaccount", "string"), 
                                                                    ("kubernetes.labels.projectName", "string", "projectname", "string"), 
                                                                    ("geo.cityResponse.registeredCountry.isoCode", "string", "isocode", "string")], transformation_ctx = "applymapping1")
from pyspark.sql.types import *
from pyspark.sql.functions import *
from pyspark.sql import functions as F
applymapping1.toDF().createOrReplaceTempView("memberships")
applymapping1.toDF().registerTempTable('memberships')
result = spark.sql("""select projectname,projectaccount,isocode,count(isocode) as thetotal
            from memberships  
            group by projectname,projectaccount,isocode""")
print('begin')

result = result.withColumn("a_timestamp",F.date_format(current_timestamp(),'YYYY-MM-dd HH:00:00'))
result = result.withColumn("a_to_timestamp_1",result.a_timestamp - F.expr('INTERVAL 1 HOURS'))
result = result.withColumn("a_to_timestamp",to_timestamp(col("a_to_timestamp_1"),"yyyy-MM-dd HH:mm:ss"))\
               .drop("a_timestamp")\
               .drop("a_to_timestamp_1")
result.show()
print('end')

from awsglue.dynamicframe import DynamicFrame
resolvechoice4 = DynamicFrame.fromDF(result, glueContext, "resolvechoice4")  
resolvechoice5 = ApplyMapping.apply(frame = resolvechoice4, mappings = [("projectname", "string", "projectname", "string"), ("projectaccount", "string", "projectaccount", "string"), ("isocode", "string", "isocode", "string"),("thetotal", "long", "thetotal", "bigint"),("a_to_timestamp", "timestamp", "a_to_timestamp", "timestamp")], transformation_ctx = "resolvechoice5")
resolvechoice5.printSchema()

datasink5 = glueContext.write_dynamic_frame.from_catalog(frame = resolvechoice5, database = "geo123", table_name = "sub123_public_geo_dis", redshift_tmp_dir = args["TempDir"], transformation_ctx = "datasink5")
job.commit()