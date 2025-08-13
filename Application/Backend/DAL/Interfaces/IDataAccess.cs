
using CodeNB.Types;
using System.Data;

namespace DAL
{
    public interface IDataAccess
    {
        //DataTable Execute(string cmdText, List<Parm>? parms = null, CommandType cmdType = CommandType.StoredProcedure);
        object ExecuteScalar(string cmdText, List<Parm>? parms = null, CommandType cmdType = CommandType.StoredProcedure);
        //int ExecuteNonQuery(string cmdText, List<Parm>? parms = null, CommandType cmdType = CommandType.StoredProcedure);

        Task<DataTable> ExecuteAsync(string cmdText, List<Parm>? parms = null, CommandType cmdType = CommandType.StoredProcedure);
        Task<object?> ExecuteScalarAsync(string cmdText, List<Parm>? parms = null, CommandType cmdType = CommandType.StoredProcedure);
        Task<int> ExecuteNonQueryAsync(string cmdText, List<Parm>? parms = null, CommandType cmdType = CommandType.StoredProcedure);
    }
}
